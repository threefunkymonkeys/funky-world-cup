require 'cuba'
require 'cuba/render'
require 'sequel'
require_relative 'helpers/environment'

ENV['RACK_ENV'] ||= :development


FunkyWorldCup::Helpers.init_environment(ENV['RACK_ENV'])

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
