class Main < Sinatra::Base
    post '/api/get_tests' do
        require_teacher!
        data = parse_request_data(:required_keys => [:start_date, :klasse])
        start_date = data[:start_date]
        end_date = (Date.parse(start_date) + 60).strftime('%Y-%m-%d')
        klasse = data[:klasse]
        events = []
        @@ferien_feiertage.each do |event|
            events << {
                :start => event[:from],
                :end => event[:to],
                :title => event[:title],
                :extendedProps => {
                    :type => :holiday
                }
            }
        end
        tests = neo4j_query(<<~END_OF_QUERY, :start_date => start_date, :end_date => end_date, :klasse => klasse).map { |x| {:user => x['u'].props, :test => x['t'].props } }
            MATCH (t:Test {klasse: {klasse}})-[:ORGANIZED_BY]->(u:User)
            WHERE t.datum >= {start_date} AND t.datum <= {end_date}
            RETURN t, u;
        END_OF_QUERY
        tests.each do |event|
            user_info = @@user_info[event[:user][:email]]
            title = "#{event[:test][:typ]} #{event[:test][:fach]} (#{@@user_info[event[:user][:email]][:shorthand]})"
            unless (event[:test][:kommentar] || '').strip.empty?
                title += " – #{event[:test][:kommentar]}"
            end
            events << {
                :start => event[:test][:datum],
                :end => event[:test][:datum],
                :title => title,
                :extendedProps => {
                    :type => :test,
                    :test => event[:test],
                    :display_name => user_info[:display_name],
                    :shorthand => user_info[:shorthand],
                    :is_session_user => event[:user][:email] == @session_user[:email]
                }
            }
        end
        respond(:events => events)
    end
    
    post '/api/save_test' do
        require_teacher!
        data = parse_request_data(:required_keys => [:klasse, :datum, :fach, :kommentar, :typ])
        id = RandomTag.generate(12)
        timestamp = Time.now.to_i
        test = neo4j_query_expect_one(<<~END_OF_QUERY, :session_email => @session_user[:email], :timestamp => timestamp, :id => id, :klasse => data[:klasse], :datum => data[:datum], :fach => data[:fach], :kommentar => data[:kommentar], :typ => data[:typ])['t'].props
            MATCH (a:User {email: {session_email}})
            CREATE (t:Test {id: {id}, klasse: {klasse}, datum: {datum}, fach: {fach}, kommentar: {kommentar}, typ: {typ}})
            SET t.created = {timestamp}
            SET t.updated = {timestamp}
            CREATE (t)-[:ORGANIZED_BY]->(a)
            RETURN t;
        END_OF_QUERY
        result = {
            :tid => test[:id], 
            :test => test
        }
        respond(:ok => true, :test => result)
    end
end
