require 'cuba'
require 'cuba/render'
require 'sequel'
require "rack/protection"
require 'omniauth-twitter'
require 'omniauth-facebook'
require 'hatch'
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
  provider :facebook, ENV['FACEBOOK_APP_ID'], ENV['FACEBOOK_SECRET']
end

Dir["./helpers/**/*.rb"].each { |file| require file }
Dir["./models/**/*.rb"].each { |file| require file }
Dir["./routes/**/*.rb"].each { |file| require file }
Dir["./validators/**/*.rb"].each { |file| require file }
Dir["./lib/**/*.rb"].each { |file| require file }

Cuba.plugin Cuba::Render
Cuba.plugin FunkyWorldCup::Helpers
Cuba.plugin FunkyWorldCup::Validators

include Cuba::Render::Helper

Cuba.define do

  on "groups" do
    on current_user do
      run FunkyWorldCup::Groups
    end

    not_found!
  end

  on get do
    on "404" do
      res.write "404"
    end

    on current_user do
      on root do
        res.redirect "/dashboard"
      end

      on "logout" do
        logout
      end

      on "dashboard" do
        @groups = CupGroup.groups_phase.all
        res.write render("./views/layouts/application.html.erb") {
          render("./views/pages/dashboard.html.erb")
        }
      end
    end

    on root do
      res.write render("./views/layouts/home.html.erb") {
        render("./views/pages/home.html.erb")
      }
    end

    on "auth/:provider/callback" do |provider|
      uid  = env['omniauth.auth']['uid']
      info = env['omniauth.auth']['info']
      info['nickname'] ||= info['name']

      unless user = User["#{provider}_user".to_sym => uid]
        user = User.create("#{provider}_user" => uid,
                           "nickname" => info['nickname'],
                           "name" => info['name'],
                           "image" => info['image'])
      end

      authenticate(user)
      res.redirect "/dashboard"
    end
  end
end
