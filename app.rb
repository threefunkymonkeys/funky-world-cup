require 'cuba'
require 'cuba/render'
require 'sequel'
require_relative 'lib/funky_world_cup'

ENV["RACK_ENV"] ||= :development
settings_file = File.join(File.dirname(__FILE__), "config/settings.yml")

FunkyWorldCupApp::Settings.load(settings_file, ENV["RACK_ENV"])
DB = FunkyWorldCupApp::Database.connect FunkyWorldCupApp::Settings.get('db')

Cuba.use Rack::Static,
          root: File.expand_path(File.dirname(__FILE__)) + "/public",
          urls: %w[/img /css /js]

Cuba.plugin Cuba::Render

Dir["./models/**/*.rb"].each     { |rb| require rb }

Cuba.define do
  on get do
    on root do
      res.write render("./views/layouts/home.html.erb") {
        render("./views/pages/home.html.erb")
      }
    end
  end
end
