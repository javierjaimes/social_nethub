require "sinatra"
require "oauth2"
require "sinatra/reloader" if development?

set :raise_errors, true
set :show_exceptions, false

API_CLIENT = OAuth2::Client.new('client_id', 'client_secret', :site => 'https://api.nethub.co')

get '/' do
  redirect "http://nethub.co"
end

get '/:id' do
  raise "error!"
end


get "/:id/callback" do
  puts params
  "Aqui con el callback " + params[ :id ]
end
