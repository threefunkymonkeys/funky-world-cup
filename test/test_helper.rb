require 'minitest/autorun'
require 'minitest/spec'
require 'pp'
require 'rack/test'
require 'spawn'
require 'faker'

ENV["RACK_ENV"]  = "test"

require File.dirname(__FILE__) + '/../app'
require File.dirname(__FILE__) + '/spawners'

class MiniTest::Spec
  include Rack::Test::Methods

  def app
    Cuba.app
  end
end

require File.dirname(__FILE__) + '/../lib/seed_loader'
SeedLoader.new(false).seed
