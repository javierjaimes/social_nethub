require "json"
require "date"
require "sinatra"
require "sinatra/reloader" if development?
require "oauth2"
require "rest_client"


set :raise_errors, true
set :show_exceptions, false

oauth2 = OAuth2::Client.new(
  'BesuYeR65yfNWqPLwcyK',
  '138448238410115309201377100117',
  {
    :site => 'https://api.nethub.co',
    :token_url => '/oauth2/token/',
    :oauth_version => 2
  }
)


get '/' do
  redirect "http://nethub.co"
end

get '/:id' do
  token = oauth2.client_credentials.get_token({}, {"auth_scheme" => "request_body"})
  begin 
    response = token.get '/app/26d06213-04d6-4ab1-b9b6-e27bf8be738f/' + params[:id]
    data = response.parsed
    unless !data[ "data" ].empty?
      halt 404
    else
      client_id = data[ "data" ][ 0 ][ "client_id" ]
      redirect_uri = "http://localhost:3000/" + params[ :id ] + "/callback"
      redirect "https://www.facebook.com/dialog/oauth?client_id=" + client_id + "&redirect_uri=" + redirect_uri + "&scope=email,user_birthday,user_likes,user_location"
    end

  rescue Exception => e
    puts e
    halt 400
  end
 #raise "error!"
end


get "/:id/callback" do
  unless !params.has_key?( "error" )
    halt 401
  end

  token = oauth2.client_credentials.get_token({}, {"auth_scheme" => "request_body"})
  begin
    response = token.get '/app/26d06213-04d6-4ab1-b9b6-e27bf8be738f/' + params[:id]
    data = response.parsed
    unless !data[ "data" ].empty?
      halt 404
    end
    
    app_data = data[ "data" ][ 0 ]


    #Getting the FB token
    client_id = app_data[ "client_id" ]
    client_secret =  app_data[ "secret_id" ]
    redirect_uri = "http://localhost:3000/" + params[ :id ] + "/callback"
    code = params[ :code ]

    begin
      fb_response = RestClient.get "https://graph.facebook.com/oauth/access_token", :params => { :client_id => client_id, :redirect_uri => redirect_uri, :client_secret => client_secret, :code => code }
      fb_response =  CGI::parse( fb_response )
      fb_token = fb_response[ "access_token" ][0]
      #fb_token = 'CAAFLyNxrkcMBAM0dTfTD2TTiPT1XlJ7bXOZAbpNdZBNnVC96ymXZCfvqkfstjdXB496lhSUyfr89P7pNVe9PpMZCj82C1loDqhLDaJUZCoHj93MzFcIWd94xE4uV3mZBnnKzYFOqA89QXXZBYfZBGBQrQZACMD8JQsThpp49FHHK5faZC9HRxXPLkQAgxuZC5jlQMUZD'

      #get user information
      response = RestClient.get 'https://graph.facebook.com/me', :params => { :access_token => fb_token }, :content_type => :json, :accept => :json
      user_info = JSON.parse( response )
      birthday = Date.strptime( user_info[ 'birthday' ], '%m/%d/%Y' )
      person = {
        :first_name => user_info[ "first_name" ],
        :last_name => user_info[ "last_name" ],
        :gender => user_info[ "gender" ],
        :birthday => birthday.strftime( '%m-%d-%Y' ),
        :identifiers => [{
          :email => user_info[ "email" ]
        }]
      }

      #save user info
      response = token.post '/person', { body: person.to_json }
      data = response.parsed
      unless data[ "success" ]
        halt 400
      end

      #get user likes
      #response = RestClient.get 'https://graph.facebook.com/me/likes', :params => { :access_token => fb_token }
      #user_likes = JSON.parse response
      #puts user_likes
      puts 'url redirect'
      puts app_data
      redirect [ app_data[ "domain" ], "/", app_data[ "callback" ] ].join 
    rescue Exception => e
      halt 500
    end

    #request the user information
    #user = RestClient.get 'https://graph.facebook.com/me'

    #puts user
  rescue Exception => e
    #puts e
    halt 400

  end
end
