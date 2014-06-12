require 'minitest/autorun'
require 'minitest/spec'
require 'pp'
require 'rack/test'
require 'spawn'
require 'faker'
require 'mocha/mini_test'
require 'pry-debugger'

ENV["RACK_ENV"]  = "test"

require File.dirname(__FILE__) + '/../app'
require File.dirname(__FILE__) + '/spawners'

class MiniTest::Spec
  include Rack::Test::Methods

  def app
    Cuba.app
  end
end

class FunkyWorldCup::TwitterNotifier
  def notify(status)
    @logger.info("TwitterNotifier TEST MODE NOTIFYING: #{status}")
  end
end

require File.dirname(__FILE__) + '/../lib/seed_loader'
SeedLoader.new(false).seed
