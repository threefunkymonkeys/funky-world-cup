require 'yaml'
require_relative File.join(File.dirname(__FILE__)) + '/../lib/funky_world_cup'

module FunkyWorldCup
  ALLOWED_LOCALES = [:en, :es]
  DEFAULT_LOCALE = :en

  module Helpers
    def self.init_environment(env)
      settings_file = File.join(File.dirname(__FILE__), "/../config/settings.yml")

      FunkyWorldCupApp::Settings.load(settings_file, env)
      @@DB = FunkyWorldCupApp::Database.connect FunkyWorldCupApp::Settings.get('db')

      I18n.enforce_available_locales = false

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

    def init_locale(env)
      if !session[:locale] && (env.has_key?("HTTP_ACCEPT_LANGUAGE") || current_user)
        if current_user.locale
          locale = current_user.locale
        else
          locale = env["HTTP_ACCEPT_LANGUAGE"][0,2].to_sym #take first accepted language
        end
        locale = DEFAULT_LOCALE unless ALLOWED_LOCALES.include?(locale)
        session[:locale] = locale
      end

      I18n.locale = session[:locale]
    end
  end
end
