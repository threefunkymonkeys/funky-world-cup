require 'minitest/spec'
require 'minitest/autorun'
require 'pp'
require 'rack/test'

ENV["RACK_ENV"]  = "test"

require File.dirname(__FILE__) + '/../app'

class MiniTest::Spec
  include Rack::Test::Methods

  def app
    Cuba.app
  end
end

