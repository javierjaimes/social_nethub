require "json"
require "date"
require "mongo"
require "bson"
require "oauth2"
require "rest_client"

LIKES = Array.new

def get_likes(url)

	event = Array.new 
	fb_likes  = RestClient.get url
	likes = JSON.parse(fb_likes)

	likes["data"].each do |l|
		event << l["name"]
	end

	if likes["paging"]["next"]
		get_likes (likes["paging"]["next"])
		
		LIKES << event
	end
	
end

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
		url = "https://graph.facebook.com//me/likes?access_token="+f["token"]
		get_likes(url)

		events = Hash.new 
		events[:events]= LIKES
		puts events

	rescue Exception => e
		puts "No connection with FB #{e}"
	end

end


