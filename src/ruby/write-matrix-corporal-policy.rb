#!/usr/bin/env ruby
# SKIP_COLLECT_DATA = true
require './main.rb'
require './parser.rb'
require 'digest/sha2'
require 'yaml'
require 'http'

class Script
    include QtsNeo4j
    def run
        @@user_info = Main.class_variable_get(:@@user_info)
        policy_json = generate_matrix_corporal_policy().to_json
        File::open('/internal/policy.json', 'w') do |f|
            f.write policy_json
        end
    end
    
    def generate_matrix_corporal_policy
        result = {
            :schemaVersion => 1,
            :flags => {
                :allowCustomUserDisplayNames => false,
                :allowCustomUserAvatars => false,
                :allowCustomPassthroughUserPasswords => false,
                :allowUnauthenticatedPasswordResets => false,
                :forbidRoomCreation => false,
                :forbidEncryptedRoomCreation => false,
                :forbidUnencryptedRoomCreation => false
            },
            :managedCommunityIds => [],
            :managedRoomIds => [],
            :users => [],
            :hooks => [],
        }
        matrix_handle_to_email = {}
        stored_etags = {}
        temp = neo4j_query(<<~END_OF_QUERY)
            MATCH (u:User)
            RETURN u.email AS email, u.avatar_etag AS etag;
        END_OF_QUERY
        temp.each do |row|
            stored_etags[row['email']] = row['etag']
        end

        host = NEXTCLOUD_URL_FROM_RUBY_CONTAINER
        begin
            http = HTTP.persistent host
            @@user_info.each_pair do |email, info|
                handle = info[:matrix_login]
                matrix_handle_to_email[handle] = email
                stored_etag = stored_etags[email]
                
                user_entry = {
                    :id => handle,
                    :active => true,
                    :authType => 'rest',
                    :authCredential => "#{WEB_ROOT}/api/confirm_chat_login",
                    :displayName => info[:teacher] ? info[:display_last_name] : info[:display_name],
                    :joinedCommunityIds => [],
                    :joinedRoomIds => [],
                }
                
                avatar_uri_nc = "#{NEXTCLOUD_URL_FROM_RUBY_CONTAINER}/index.php/avatar/#{info[:nc_login]}/512"
                STDERR.write '.'
                headers = {}
                headers['If-None-Match'] = stored_etag.split('.').first if stored_etag
                STDERR.puts "#{email} #{stored_etag.split('.').first}"
                response = http.headers(headers).get("/index.php/avatar/#{info[:nc_login]}/512")
                etag = response.headers['ETag'].gsub('"', '')
                content_type = response.headers['Content-Type']
                ext = content_type == 'image/png' ? 'png' : 'jpg'
                etag_ext = "#{etag}.#{ext}"
                avatar_cache_path = "/gen/a/#{etag[0, 2]}/#{etag[2, etag.size]}.#{ext}"
                if response.status.success?
                    STDERR.puts "Re-caching #{avatar_uri_nc} to #{avatar_cache_path}"
                    unless File::exists?(avatar_cache_path)
                        FileUtils::mkpath(File::dirname(avatar_cache_path))
                        File.open(avatar_cache_path, 'w') do |f|
                            f.write response.body
                        end
                    end
                    stored_etags[email] = etag
                    temp = neo4j_query(<<~END_OF_QUERY, :email => email, :etag => etag_ext)
                        MATCH (u:User {email: {email}})
                        SET u.avatar_etag = {etag};
                    END_OF_QUERY
                end
                user_entry[:avatarUri] = "#{WEB_ROOT}#{avatar_cache_path}"
                
                result[:users] << user_entry
            end
        ensure
            http.close if http
        end
            
        result[:hooks] << {
            :id => 'dashboard-hook-before-create-room',
            :eventType => 'beforeAuthenticatedRequest',
            :matchRules => [
                {:type => 'method', :regex => 'POST'},
                {:type => 'route', :regex => '^/_matrix/client/r0/createRoom'}
            ],
            :action => 'consult.RESTServiceURL',
            :RESTServiceURL => "#{WEB_ROOT}/api/matrix_hook",
            :RESTServiceRequestHeaders => {
                "Authorization" => "Bearer #{MATRIX_CORPORAL_CALLBACK_BEARER_TOKEN}",
            },
            :RESTServiceRequestTimeoutMilliseconds => 10000,
            :RESTServiceRetryAttempts => 1,
            :RESTServiceRetryWaitTimeMilliseconds => 5000
        }
        result[:hooks] << {
            :id => 'dashboard-hook-before-leave-room',
            :eventType => 'beforeAuthenticatedRequest',
            :matchRules => [
                {:type => 'method', :regex => 'POST'},
                {:type => 'route', :regex => '^/_matrix/client/r0/rooms/([^/]+)/leave'}
            ],
            :action => 'consult.RESTServiceURL',
            :RESTServiceURL => "#{WEB_ROOT}/api/matrix_hook",
            :RESTServiceRequestHeaders => {
                "Authorization" => "Bearer #{MATRIX_CORPORAL_CALLBACK_BEARER_TOKEN}",
            },
            :RESTServiceRequestTimeoutMilliseconds => 10000,
            :RESTServiceRetryAttempts => 1,
            :RESTServiceRetryWaitTimeMilliseconds => 5000
        }
        result[:hooks] << {
            :id => 'dashboard-hook-before-enable-encryption',
            :eventType => 'beforeAuthenticatedRequest',
            :matchRules => [
                {:type => 'method', :regex => 'PUT'},
                {:type => 'route', :regex => '^/_matrix/client/r0/rooms/([^/]+)/state/m.room.encryption/'}
            ],
            :action => 'consult.RESTServiceURL',
            :RESTServiceURL => "#{WEB_ROOT}/api/matrix_hook",
            :RESTServiceRequestHeaders => {
                "Authorization" => "Bearer #{MATRIX_CORPORAL_CALLBACK_BEARER_TOKEN}",
            },
            :RESTServiceRequestTimeoutMilliseconds => 10000,
            :RESTServiceRetryAttempts => 1,
            :RESTServiceRetryWaitTimeMilliseconds => 5000
        }
        result
    end
end

script = Script.new
script.run
