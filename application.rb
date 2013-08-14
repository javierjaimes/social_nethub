require "sinatra"
require "rest_client"
require "sinatra/reloader" if development?


get '/' do
  "Hola mundo 2"
end

get '/:id' do
  puts params
  "Aqui con id " + params[ :id ]
end


get "/:id/callback" do
  puts params
  "Aqui con el callback " + params[ :id ]
end
