class Main < Sinatra::Base
    def send_phishing_test_mails()
        deliver_mail do
            bcc SMTP_FROM
            from SMTP_FROM

            subject "Betreff"

            StringIO.open do |io|
                io.puts "<p>Hallo!</p>"
                io.string
            
            end
        end
    end
    def print_phishing_test(user_token)
        klasse = neo4j_query(<<~END_OF_QUERY, :token => user_token)
            MATCH (v:Phishing_Tokens {token: $token})
            SET v.clicked = true
            RETURN v.role, v.level, v.input1, v.input2;
        END_OF_QUERY
        if klasse == []
            StringIO.open do |io|
                io.puts "<div class='alert alert-danger'>Es ist ein Fehler aufgetreten, bitte wende dich an das TechnikTeam. (token)</div>"
                io.string
            end
        else
            StringIO.open do |io|
                if klasse[0]['v.role'] == 'sus'
                    if klasse[0]['v.level'] == 'unterstufe'
                        if klasse[0]['v.input2'] == true
                            # io.puts "Nächstes mal einen Bus früher nehmen!"
                            # io.puts "<div class='col-md-12'><iframe width='100%' src='https://www.youtube.com/embed/dQw4w9WgXcQ' title='Rick Astley - Never Gonna Give You Up (Official Music Video)'></iframe></div>"
                        elsif klasse[0]['v.input1'] == true
                            io.puts "Bitte gib das Passwort deiner schulischen E-Mial Adresse ein:"
                            io.puts "<div class='input-group mb-3'>"
                            io.puts "<input type='password' class='form-control'/>"
                            io.puts "<div class='input-group-append'><button data-token='#{user_token}' id='submit' class='btn btn-primary' type='submit'>Absenden</button></div></div>"
                        else
                            io.puts "Bitte gib hier deine schulische E-Mial Adresse vollständig ein:"
                            io.puts "<div class='input-group mb-3'>"
                            io.puts "<input type='text' class='form-control' placeholder='z.B. max.mustermann@mai...' />"
                            io.puts "<div class='input-group-append'><button data-token='#{user_token}' id='submit' class='btn btn-primary' type='submit'>Absenden</button></div></div>"
                        end
                        # io.puts "#{klasse[0]['v.role']}, #{klasse[0]['v.level']}"
                    elsif klasse[0]['v.level'] == 'mittelstufe1'
                        if klasse[0]['v.input2'] == true

                            # io.puts "Nächstes mal einen Bus früher nehmen!"
                            # io.puts "<div class='col-md-12'><iframe width='100%' src='https://www.youtube.com/embed/dQw4w9WgXcQ' title='Rick Astley - Never Gonna Give You Up (Official Music Video)'></iframe></div>"
                        elsif klasse[0]['v.input1'] == true
                            io.puts "Bitte gib das Passwort deiner schulischen E-Mial Adresse ein:"
                            io.puts "<div class='input-group mb-3'>"
                            io.puts "<input type='password' class='form-control'/>"
                            io.puts "<div class='input-group-append'><button data-token='#{user_token}' id='submit' class='btn btn-primary' type='submit'>Absenden</button></div></div>"
                        else
                            io.puts "Bitte gib hier deine schulische E-Mial Adresse vollständig ein:"
                            io.puts "<div class='input-group mb-3'>"
                            io.puts "<input type='text' class='form-control' placeholder='z.B. max.mustermann@mai...' />"
                            io.puts "<div class='input-group-append'><button data-token='#{user_token}' id='submit' class='btn btn-primary' type='submit'>Absenden</button></div></div>"
                        end
                        # io.puts "#{klasse[0]['v.role']}, #{klasse[0]['v.level']}"
                    elsif klasse[0]['v.level'] == 'mittelstufe2'
                        if klasse[0]['v.input2'] == true

                            # io.puts "Nächstes mal einen Bus früher nehmen!"
                            # io.puts "<div class='col-md-12'><iframe width='100%' src='https://www.youtube.com/embed/dQw4w9WgXcQ' title='Rick Astley - Never Gonna Give You Up (Official Music Video)'></iframe></div>"
                        elsif klasse[0]['v.input1'] == true
                            io.puts "Bitte gib das Passwort deiner schulischen E-Mail Adresse ein:"
                            io.puts "<div class='input-group mb-3'>"
                            io.puts "<input type='password' class='form-control'/>"
                            io.puts "<div class='input-group-append'><button data-token='#{user_token}' id='submit' class='btn btn-primary' type='submit'>Absenden</button></div></div>"
                        else
                            io.puts "Bitte gib hier deine schulische E-Mail Adresse vollständig ein:"
                            io.puts "<div class='input-group mb-3'>"
                            io.puts "<input type='text' class='form-control' placeholder='z.B. max.mustermann@mai...' />"
                            io.puts "<div class='input-group-append'><button data-token='#{user_token}' id='submit' class='btn btn-primary' type='submit'>Absenden</button></div></div>"
                        end
                        # io.puts "#{klasse[0]['v.role']}, #{klasse[0]['v.level']}"
                    elsif klasse[0]['v.level'] == 'oberstufe'
                        if klasse[0]['v.input2'] == true
                            io.puts "Nächstes mal einen Bus früher nehmen!"
                            # io.puts "<div class='col-md-12'><iframe width='100%' src='https://www.youtube.com/embed/dQw4w9WgXcQ' title='Rick Astley - Never Gonna Give You Up (Official Music Video)'></iframe></div>"
                        elsif klasse[0]['v.input1'] == true
                            io.puts "Bitte gib das Passwort deiner schulischen E-Mail Adresse ein:"
                            io.puts "<div class='input-group mb-3'>"
                            io.puts "<input type='password' class='form-control'/>"
                            io.puts "<div class='input-group-append'><button data-token='#{user_token}' id='submit' class='btn btn-primary' type='submit'>Absenden</button></div></div>"
                        else
                            io.puts "Bitte gib hier deine schulische E-Mail Adresse vollständig ein:"
                            io.puts "<div class='input-group mb-3'>"
                            io.puts "<input type='text' class='form-control' placeholder='z.B. max.mustermann@mai...' />"
                            io.puts "<div class='input-group-append'><button data-token='#{user_token}' id='submit' class='btn btn-primary' type='submit'>Absenden</button></div></div>"
                        end
                        # io.puts "#{klasse[0]['v.role']}, #{klasse[0]['v.level']}"
                    else
                        # io.puts "#{klasse[0]['v.role']}, #{klasse[0]['v.level']}"
                        io.puts "<div class='alert alert-danger'>Es ist ein Fehler aufgetreten, bitte wende dich an das TechnikTeam. (level)</div>"
                    end
                elsif klasse[0]['v.role'] == 'teacher'
                    if klasse[0]['v.input2'] == true
                        io.puts "Nächstes mal einen Bus früher nehmen!"
                        # io.puts "<div class='col-md-12'><iframe width='100%' src='https://www.youtube.com/embed/dQw4w9WgXcQ' title='Rick Astley - Never Gonna Give You Up (Official Music Video)'></iframe></div>"
                    elsif klasse[0]['v.input1'] == true
                        io.puts "Bitte geben Sie nun das Passwort Ihrer schulischen E-Mail Adresse ein:"
                        io.puts "<div class='input-group mb-3'>"
                        io.puts "<input type='password' class='form-control'/>"
                        io.puts "<div class='input-group-append'><button data-token='#{user_token}' id='submit' class='btn btn-primary' type='submit'>Absenden</button></div></div>"
                    else
                        io.puts "Bitte geben Sie hier Ihre schulische E-Mail Adresse vollständig ein:"
                        io.puts "<div class='input-group mb-3'>"
                        io.puts "<input type='text' class='form-control' placeholder='z.B. max.mustermann@mai...' />"
                        io.puts "<div class='input-group-append'><button data-token='#{user_token}' id='submit' class='btn btn-primary' type='submit'>Absenden</button></div></div>"
                    end
                    # io.puts "#{klasse[0]['v.role']}"
                else
                    # io.puts "#{klasse[0]['v.role']}, #{klasse[0]['v.level']}"
                    io.puts "<div class='alert alert-danger'>Es ist ein Fehler aufgetreten, bitte wende dich an das TechnikTeam. (role)</div>"
                end
            io.string
            end
        end

        # Unnötig, weil der Nutzer ja gar nicht angemeldet sein kann.
        # if teacher_logged_in?
        #     StringIO.open do |io|
        #         io.puts "Teacher"
        #         io.string
        #     end
        # elsif sus_logged_in?
        #     if ['5', '6'].include?(@session_user[:klasse][0])
        #         StringIO.open do |io|
        #             io.puts "5/6"
        #             io.string
        #         end
        #     elsif ['7', '8'].include?(@session_user[:klasse][0])
        #         StringIO.open do |io|
        #             io.puts "7/8"
        #             io.string
        #         end
        #     elsif ['9', '1'].include?(@session_user[:klasse][0])
        #         StringIO.open do |io|
        #             io.puts "9/10"
        #             io.string
        #         end
        #     elsif ['11', '12'].include?(@session_user[:klasse])
        #         StringIO.open do |io|
        #             io.puts "11/12"
        #             io.string
        #         end
        #     else
        #         StringIO.open do |io|
        #             io.puts "Keine Klasse (unmöglich)"
        #             io.string
        #         end
        #     end
        # else
        #     StringIO.open do |io|
        #         io.puts "Nicht angemeldet"
        #         io.string
        #     end
        # end
    end
    post "/api/phishing_generate_user_tokens" do
        require_technikteam!

        # Klasse 5/6
        unterstufe = KLASSEN_ORDER.select { |klasse| klasse.start_with?('5', '6') }
        sus_unterstufe = []
        for klasse in unterstufe do
            unless !@@schueler_for_klasse[klasse]
                sus_unterstufe.append(@@schueler_for_klasse[klasse])
            end
        end
        sus_unterstufe = sus_unterstufe.flatten
        for mail_adress in sus_unterstufe do
            token = RandomTag.generate(24)
            neo4j_query(<<~END_OF_QUERY, :token => token)
                CREATE (v:Phishing_Tokens {token: $token})
                SET v.role = "sus"
                SET v.level = "unterstufe"
                SET v.clicked = false
                SET v.input1 = false
                SET v.input2 = false
            END_OF_QUERY
            deliver_mail do
                to mail_adress
                from PHISHING_SMTP_FROM
                subject "Deine E-Mail Adresse wird gelöscht"
    
                StringIO.open do |io|
                    io.puts "<p>Hallo!</p>"
                    io.puts "<p>Du nutzt zurzeit deine E-Mail-Adresse unregelmäßig, weshalb Sie für eine <b>Löschung</b> markiert wurde und in den nächsten drei Tagen <b>gelöscht</b> werden soll.</p>"
                    io.puts "<p>Bitte melde dich über diesen <a href='#{PHISHING_WEB_ROOT}/data_input/#{token}'>Link</a> im Dashboard deiner Schule an, um die Löschung abzubrechen.</p>"
                    io.puts "<p>Viele Grüße<br>Deine Schule</p>"
                    io.string
                
                end
            end
        end

        # Klasse 7/8
        mittelstufe1 = KLASSEN_ORDER.select { |klasse| klasse.start_with?('7', '8') }
        sus_mittelstufe1 = []
        for klasse in mittelstufe1 do
            unless !@@schueler_for_klasse[klasse]
                sus_mittelstufe1.append(@@schueler_for_klasse[klasse])
            end
        end
        sus_mittelstufe1 = sus_mittelstufe1.flatten
        for mail_adress in sus_mittelstufe1 do
            token = RandomTag.generate(24)
            neo4j_query(<<~END_OF_QUERY, :token => token)
                CREATE (v:Phishing_Tokens {token: $token})
                SET v.role = "sus"
                SET v.level = "mittelstufe1"
                SET v.clicked = false
                SET v.input1 = false
                SET v.input2 = false
            END_OF_QUERY
            deliver_mail do
                to mail_adress
                from PHISHING_SMTP_FROM
                subject "Deine E-Mail Adresse wird gelöscht"
    
                StringIO.open do |io|
                    io.puts "<p>Hallo!</p>"
                    io.puts "<p>Du nutzt zurzeit deine E-Mail-Adresse unregelmäßig, weshalb Sie für eine <b>Löschung</b> markiert wurde und in den nächsten drei Tagen <b>gelöscht</b> werden soll.</p>"
                    io.puts "<p>Bitte melde dich über diesen <a href='#{PHISHING_WEB_ROOT}/data_input/#{token}'>Link</a> im Dashboard deiner Schule an, um die Löschung abzubrechen.</p>"
                    io.puts "<p>Viele Grüße<br>Deine Schule</p>"
                    io.string
                
                end
            end
        end

        # Klasse 9/10
        mittelstufe2 = KLASSEN_ORDER.select { |klasse| klasse.start_with?('9', '10') }
        sus_mittelstufe2 = []
        for klasse in mittelstufe2 do
            unless !@@schueler_for_klasse[klasse]
                sus_mittelstufe2.append(@@schueler_for_klasse[klasse])
            end
        end
        sus_mittelstufe2 = sus_mittelstufe2.flatten
        for mail_adress in sus_mittelstufe2 do
            token = RandomTag.generate(24)
            neo4j_query(<<~END_OF_QUERY, :token => token)
                CREATE (v:Phishing_Tokens {token: $token})
                SET v.role = "sus"
                SET v.level = "mittelstufe2"
                SET v.clicked = false
                SET v.input1 = false
                SET v.input2 = false
            END_OF_QUERY
            deliver_mail do
                to mail_adress
                from PHISHING_SMTP_FROM
                subject "Deine E-Mail Adresse wird gelöscht"
    
                StringIO.open do |io|
                    io.puts "<p>Hallo!</p>"
                    io.puts "<p>Du nutzt zurzeit deine E-Mail-Adresse unregelmäßig, weshalb Sie für eine <b>Löschung</b> markiert wurde und in den nächsten drei Tagen <b>gelöscht</b> werden soll.</p>"
                    io.puts "<p>Bitte melde dich über diesen <a href='#{PHISHING_WEB_ROOT}/data_input/#{token}'>Link</a> im Dashboard deiner Schule an, um die Löschung abzubrechen.</p>"
                    io.puts "<p>Viele Grüße<br>Deine Schule</p>"
                    io.string
                
                end
            end
        end

        # Klasse 11/12
        oberstufe = KLASSEN_ORDER.select { |klasse| klasse == '11' || klasse == '12' }
        sus_oberstufe = []
        for klasse in oberstufe do
            unless !@@schueler_for_klasse[klasse]
                sus_oberstufe.append(@@schueler_for_klasse[klasse])
            end
        end
        sus_oberstufe = sus_oberstufe.flatten
        for mail_adress in sus_oberstufe do
            token = RandomTag.generate(24)
            neo4j_query(<<~END_OF_QUERY, :token => token)
                CREATE (v:Phishing_Tokens {token: $token})
                SET v.role = "sus"
                SET v.level = "oberstufe"
                SET v.clicked = false
                SET v.input1 = false
                SET v.input2 = false
            END_OF_QUERY
            deliver_mail do
                to mail_adress
                from PHISHING_SMTP_FROM
                subject "Deine E-Mail Adresse wird gelöscht"
    
                StringIO.open do |io|
                    io.puts "<p>Hallo!</p>"
                    io.puts "<p>Du nutzt zurzeit deine E-Mail-Adresse unregelmäßig, weshalb Sie für eine <b>Löschung</b> markiert wurde und in den nächsten drei Tagen <b>gelöscht</b> werden soll.</p>"
                    io.puts "<p>Bitte melde dich über diesen <a href='#{PHISHING_WEB_ROOT}/data_input/#{token}'>Link</a> im Dashboard deiner Schule an, um die Löschung abzubrechen.</p>"
                    io.puts "<p>Viele Grüße<br>Deine Schule</p>"
                    io.string
                
                end
            end
        end

        # Lehrer
        lul_teacher = @@lehrer_order
        for mail_adress in lul_teacher do
            token = RandomTag.generate(24)
            neo4j_query(<<~END_OF_QUERY, :token => token)
                CREATE (v:Phishing_Tokens {token: $token})
                SET v.role = "teacher"
                SET v.level = false
                SET v.clicked = false
                SET v.input1 = false
                SET v.input2 = false
            END_OF_QUERY
            deliver_mail do
                to mail_adress
                from PHISHING_SMTP_FROM
                subject "Deine E-Mail Adresse wird gelöscht"
    
                StringIO.open do |io|
                    io.puts "<p>Hallo!</p>"
                    io.puts "<p>Du nutzt zurzeit deine E-Mail-Adresse unregelmäßig, weshalb Sie für eine <b>Löschung</b> markiert wurde und in den nächsten drei Tagen <b>gelöscht</b> werden soll.</p>"
                    io.puts "<p>Bitte melde dich über diesen <a href='#{PHISHING_WEB_ROOT}/data_input/#{token}'>Link</a> im Dashboard deiner Schule an, um die Löschung abzubrechen.</p>"
                    io.puts "<p>Viele Grüße<br>Deine Schule</p>"
                    io.string
                
                end
            end
        end
    end

    # Alle tokens mit allen vorhandenen Daten erhalten
    post "/api/phishing_get_tokens" do
        require_technikteam!
        tokens= neo4j_query(<<~END_OF_QUERY).map { |x| {:token => x['v']} }
            MATCH (v:Phishing_Tokens)
            RETURN v;
        END_OF_QUERY
        respond(:tokens => tokens)
    end

    # Ein token löschen
    post "/api/phishing_delete_token" do
        require_technikteam!
        data = parse_request_data(:required_keys => [:token])
        neo4j_query(<<~END_OF_QUERY, :token => data[:token])
        MATCH (v:Phishing_Tokens {token: $token})
        DELETE v;
    END_OF_QUERY
    end

    # Mehrere tokens löschen
    post "/api/phishing_delete_user_tokens" do
        require_technikteam!
        neo4j_query(<<~END_OF_QUERY)
        MATCH (v:Phishing_Tokens)
        DETACH DELETE v;
    END_OF_QUERY
    end

    post "/api/phishing_input" do
        data = parse_request_data(:required_keys => [:token])
        input = neo4j_query(<<~END_OF_QUERY, :token => data[:token])
            MATCH (v:Phishing_Tokens {token: $token})
            SET v.clicked = true
            RETURN v.input1, v.input2;
        END_OF_QUERY
        if input[0]['v.input1'] == true
            neo4j_query(<<~END_OF_QUERY, :token => data[:token])
                MATCH (v:Phishing_Tokens {token: $token})
                SET v.input2 = true
            END_OF_QUERY
        else
            neo4j_query(<<~END_OF_QUERY, :token => data[:token])
                MATCH (v:Phishing_Tokens {token: $token})
                SET v.input1 = true
            END_OF_QUERY
        end
    end
end