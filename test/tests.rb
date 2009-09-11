require 'app.rb'
require 'test/unit'
require 'rack/test'

set :environment, :test

class GeoWorldTest < Test::Unit::TestCase
  
  include Rack::Test::Methods

  def app 
    Sinatra::Application
  end
  
  def test_it_responds
    get '/'
    assert last_response.ok?
  end
  
  def test_a_search_query
    get '/search', :q=>'virginia'
    assert last_response.body =~ /Virginia Statewide datasets \(datastack\)/m
  end
  
  def test_a_search_query_with_a_space
    get '/search', :q=>'west virginia'
    assert last_response.body =~ /Virginia Historical Counties/m
  end
  
end