require "json"
require "date"
require "mongo"
require "bson"
require "oauth2"
require "rest_client"


# set oauth2

oauth2 = OAuth2::Client.new(
  'BesuYeR65yfNWqPLwcyK',
  '138448238410115309201377100117',
  {
    :site => 'https://api.nethub.co',
    :token_url => '/oauth2/token/',
    :oauth_version => 2
  }
)
#set connection

mongoclient = Mongo::MongoClient.new
db = mongoclient.db( "social_nethub" )
token = oauth2.client_credentials.get_token({}, {"auth_scheme" => "request_body"})

#Databases
datab = db.collection( "users" )
users = datab.find({read: false})

users.each do |f|
	#conect to facebook
	begin
		event = Array.new 
		events = Hash.new 
		user_data = Hash.new

		#Likes
		fb_likes  = RestClient.get "https://graph.facebook.com//me/likes?access_token="+f["token"] 
		#parce json
		likes = JSON.parse(fb_likes)

		#Add res to event array
		likes["data"].each do |l|
			event << l["name"]
		end

		user_data[:isFan] = event
		
		events[:events]= user_data
		
		begin
			nethub_res =  token.post "#{f.user_id}" + events[:events]

			pusts "TODO ESTA OK"
		rescue Exception => e
			puts "Error en Api nethub #{e}"
		end

	rescue Exception => e
		puts "No connection with FB #{e}"
	end

end

