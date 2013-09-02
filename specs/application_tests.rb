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

  it "the app had an error" do
    get '/123'
    last_response.status.should == 400
  end

  it "the app id isn't exits" do
    get '/78f9370e-911a-4a88-9aad-226ef63a7535'
    last_response.status.should == 404
  end

  it "the app exist should be a redirect to facebook" do
    get '/78f9370e-911a-4a88-9aad-226ef63a7533'
    last_response.should be_redirect
    follow_redirect!
    last_request.url.should match /https:\/\/www.facebook.com\/dialog\/oauth\?client_id=[0-9]*\&redirect_uri=.*\&scope=[a-z,]*/i
  end

  it "the app callback is an error" do
    get '/78f9370e-911a-4a88-9aad-226ef63a7533/callback?error=access_denied&error_code=200&error_description=Permissions+error&error_reason=user_denied#_=_'
    last_response.status.should == 401
  end

  it "the app callback doesn't exists" do
    get '/78f9370e-911a-4a88-9aad-226ef63a7535/callback'
    last_response.status.should == 404
  end

  it "the code disabled at fb" do
    get '/78f9370e-911a-4a88-9aad-226ef63a7533/callback?code=AQDp-att_oaQG0DM_zAM9JhmEWoO65eBIryCzq4oVZykUS7gePwBXx_wEFs_5EkMceqcefYBFmK7sA3gbvhqtycd4e0Zsvbup1huRb4zGYElWlM_EymD120OAUyxclgtDHlPR9k6STyZcD8k96mkGhu1kmtS-PzaNniqpmC9Kl8sfTFCF8RyW3ESWO2pUEIWUL-Qv31PUk7rLTu6mg3_d_elNry6EqNzG185ruh_qHr5y1M0FgsK6PHAdq3TifnH63DuCTCZly_czDMUV7bOpNcKwIiRyKaoT6FSTulrBp6STs6aaDUC4po1tunL57ZXC1o'
    last_response.status.should == 500
  end

  it "the app callback had an error " do
    get '/123/callback'
    last_response.status.should == 400
  end

  #it "Creating the user has an error" do
  #  get '/78f9370e-911a-4a88-9aad-226ef63a7533/callback?code=AQDf1TLW4cwLP7bm1IfMFNxsCiAFBwFQOgSTcna4VwBMFrEVDdRWXkcqQY0NhMhCgBYRQk9ClQ9-WtYRaAxglE_B3R7o1T9g3T12WuRws8MypHHQKWOHlYcfbPdEkidO4eZ4DmUOBT-64QbMsWLOiPSLFuiTB8kiuyoLxuf0r9Y6vfb3XBVzddrZHCtjRmK-iXPd9pCg_si2_N_xI0jz23uM1UEsaxaDzh8p1EC1pwQY9xHfXcErxQqCIJchONMoWXY3g9my-_8kWg0W-Ydn2Ae5jPMRDfq4VZTbxdPxlCTvtCRIYf9LJKm9YffQWPQ9IRU'
  #  last_response.status.should == 400
  #end

  it "the app callback is a valid response" do
    get '/78f9370e-911a-4a88-9aad-226ef63a7533/callback?code=AQDf1TLW4cwLP7bm1IfMFNxsCiAFBwFQOgSTcna4VwBMFrEVDdRWXkcqQY0NhMhCgBYRQk9ClQ9-WtYRaAxglE_B3R7o1T9g3T12WuRws8MypHHQKWOHlYcfbPdEkidO4eZ4DmUOBT-64QbMsWLOiPSLFuiTB8kiuyoLxuf0r9Y6vfb3XBVzddrZHCtjRmK-iXPd9pCg_si2_N_xI0jz23uM1UEsaxaDzh8p1EC1pwQY9xHfXcErxQqCIJchONMoWXY3g9my-_8kWg0W-Ydn2Ae5jPMRDfq4VZTbxdPxlCTvtCRIYf9LJKm9YffQWPQ9IRU'
    last_response.should be_redirect
  end

end
