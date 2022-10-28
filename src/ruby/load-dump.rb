#!/usr/bin/env ruby

require 'neo4j_bolt'
require 'json'
require 'yaml'

class LoadDump
    include Neo4jBolt

    def run(path)
        unless ARGV.include?('--append-srsly')
            transaction do
                node_count = neo4j_query_expect_one('MATCH (n) RETURN COUNT(n) as count;')['count']
                unless node_count == 0
                    STDERR.puts "Error: There are nodes in this database, exiting now."
                    exit(1)
                end
            end
        end
        n_count = 0
        r_count = 0
        node_tr = {}
        node_batch_by_label = {}
        relationship_batch_by_type = {}
        File.open(path) do |f|
            f.each_line do |line|
                line.strip!
                next if line.empty?
                if line[0] == 'n'
                    line = line[2, line.size - 2]
                    node = JSON.parse(line)
                    label_key = node['labels'].sort.join('/')
                    node_batch_by_label[label_key] ||= []
                    node_batch_by_label[label_key] << node
                elsif line[0] == 'r'
                    line = line[2, line.size - 2]
                    relationship = JSON.parse(line)
                    relationship_batch_by_type[relationship['type']] ||= []
                    relationship_batch_by_type[relationship['type']] << relationship
                else
                    STDERR.puts "Invalid entry: #{line}"
                    exit(1)
                end
            end
        end
        node_batch_by_label.each_pair do |label_key, batch|
            while !batch.empty? do
                slice = []
                json_size = 0
                while (!batch.empty?) && json_size < 0x20000 && slice.size < 256
                    x = batch.shift
                    slice << x
                    json_size += x.to_json.size
                end
                ids = neo4j_query(<<~END_OF_QUERY, {:properties => slice.map { |x| x['properties']}})
                    UNWIND $properties AS props
                    CREATE (n:#{slice.first['labels'].join(':')})
                    SET n = props
                    RETURN ID(n) AS id;
                END_OF_QUERY
                slice.each.with_index do |node, i|
                    node_tr[node['id']] = ids[i]['id']
                end
                n_count += slice.size
                STDERR.print "\rLoaded #{n_count} nodes, #{r_count} relationships..."
            end
        end
        relationship_batch_by_type.each_pair do |rel_type, batch|
            batch.each_slice(256) do |slice|
                slice.map! do |rel|
                    rel['from'] = node_tr[rel['from']]
                    rel['to'] = node_tr[rel['to']]
                    rel
                end
                count = neo4j_query_expect_one(<<~END_OF_QUERY, {:slice => slice})['count_r']
                    UNWIND $slice AS props
                    MATCH (from), (to) WHERE ID(from) = props.from AND ID(to) = props.to
                    CREATE (from)-[r:#{rel_type}]->(to)
                    SET r = props.properties
                    RETURN COUNT(r) AS count_r, COUNT(from) AS count_from, COUNT(to) AS count_to;
                END_OF_QUERY
                if count != slice.size
                    raise "Ooops... expected #{slice.size} relationships, got #{count}."
                end
                r_count += slice.size
                STDERR.print "\rLoaded #{n_count} nodes, #{r_count} relationships..."
            end
        end

        STDERR.puts
    end
end

load = LoadDump.new
load.run(ARGV.first)
