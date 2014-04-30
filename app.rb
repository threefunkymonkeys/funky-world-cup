require 'cuba'
require 'cuba/render'
require 'sequel'
require "rack/protection"
require 'omniauth-twitter'
require_relative 'helpers/environment'

ENV['RACK_ENV'] ||= :development


FunkyWorldCup::Helpers.init_environment(ENV['RACK_ENV'])

Cuba.use Rack::Static,
          root: File.expand_path(File.dirname(__FILE__)) + "/public",
          urls: %w[/img /css /js]

Cuba.use Rack::Session::Cookie, :secret => "67569f63912747f4a11a6fd579a39c888054a984542a42568574f5bce3ceba5a"
Cuba.use Rack::Protection
Cuba.use Rack::MethodOverride

Cuba.use OmniAuth::Builder do
  provider :twitter, ENV['TWITTER_KEY'], ENV['TWITTER_SECRET']
end


Cuba.plugin Cuba::Render

Dir["./models/**/*.rb"].each     { |rb| require rb }

Cuba.define do
  on get do
    on root do
      res.write render("./views/layouts/home.html.erb") {
        render("./views/pages/home.html.erb")
      }
    end

    on "auth/:provider/callback" do |provider|
      info = env['omniauth.auth']['info']
    end
  end
end
