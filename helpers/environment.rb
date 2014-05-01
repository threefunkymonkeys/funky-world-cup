require 'yaml'
require_relative File.join(File.dirname(__FILE__)) + '/../lib/funky_world_cup'

module FunkyWorldCup
  module Helpers
    def self.init_environment(env)
      settings_file = File.join(File.dirname(__FILE__), "/../config/settings.yml")

      FunkyWorldCupApp::Settings.load(settings_file, env)
      @@DB = FunkyWorldCupApp::Database.connect FunkyWorldCupApp::Settings.get('db')

      self.set_env(env)
    end

    def self.database
      @@DB
    end

    def self.set_env(env)
      filename = env.to_s + ".env.sh"
      env_vars = File.read(filename)
      env_vars.each_line do |var|
        name, value = var.split("=")
        ENV[name.strip] = value.strip
      end
    end
  end
end
