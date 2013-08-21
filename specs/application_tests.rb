ENV['RACK_ENV'] = 'test'

require './application'
require 'rspec'
require 'rack/test'


RSpec.configure do |conf|
    conf.include Rack::Test::Methods
end

describe "Application App" do

  def app
    Sinatra::Application
  end

  it "index redirect" do
    get '/'
    last_response.should be_redirect
    follow_redirect!
    last_request.url.should == 'http://nethub.co/'
  end

  it "the app id doesn't exist" do
    get '/123'
    last_response.shoud be_redirect
  end
end
