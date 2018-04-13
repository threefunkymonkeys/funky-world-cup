require 'cuba'
require 'cuba/render'
require 'tilt/erb'
require 'sequel'
require "rack/protection"
require 'omniauth-twitter'
require 'omniauth-facebook'
require 'hatch'
require 'i18n'
require 'sass/plugin/rack'

require_relative 'helpers/environment'

ENV['RACK_ENV'] ||= :development

I18n.load_path += Dir['./locale/**/*.yml']
Encoding.default_internal, Encoding.default_external = ['utf-8'] * 2

FunkyWorldCup::Helpers.init_environment(ENV['RACK_ENV'])

Cuba.use Rack::Static,
          root: File.expand_path(File.dirname(__FILE__)) + "/public",
          urls: %w[/img /css /js /fonts]

Cuba.use Rack::Session::Cookie, :secret => ENV["SESSION_SECRET"]
Cuba.use Rack::Protection
Cuba.use Rack::MethodOverride

Cuba.use OmniAuth::Builder do
  provider :twitter, ENV['TWITTER_KEY'], ENV['TWITTER_SECRET']
  provider :facebook, ENV['FACEBOOK_APP_ID'], ENV['FACEBOOK_SECRET']
end

Dir["./helpers/**/*.rb"].each { |file| require file }
Dir["./models/**/*.rb"].each { |file| require file }
Dir["./contexts/**/*.rb"].each { |file| require file }
Dir["./validators/**/*.rb"].each { |file| require file }
Dir["./lib/**/*.rb"].each { |file| require file }

Cuba.plugin Cuba::Render
Cuba.plugin FunkyWorldCup::Helpers
Cuba.plugin FunkyWorldCup::Helpers::ContentFor
Cuba.plugin FunkyWorldCup::Validators

Cuba.use Sass::Plugin::Rack

Sass::Plugin.options[:style] = :compressed
Sass::Plugin.options[:template_location] = { "./assets/sass" => "public/css" }

include Cuba::Render::Helper

# Load all plugins before requiring routes
Dir["./routes/**/*.rb"].each { |file| require file }

Cuba.define do
  init_locale(req.env)
  session[:notifications] = current_user.get_and_read_notifications if current_user
  @@champion  ||= FunkyWorldCup.champion

  authenticate(User.first)
  #on default do
    #res.write render("./views/pages/coming_soon.html.erb")
  #end

  on "groups" do
    run FunkyWorldCup::Groups
  end

  on "cup-groups" do
    run FunkyWorldCup::CupGroups
  end

  on "users" do
    run FunkyWorldCup::Users
  end

  on "admin" do
    run FunkyWorldCup::Admin
  end

  on "teams" do
    run FunkyWorldCup::Teams
  end

  run FunkyWorldCup::Main
end
