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
    on "join/:code" do |code|
      on current_user do
        if group = Group.find(link: code)
          begin
            GroupsUser.create(group_id: group.id, user_id: current_user.id)
            authenticate(User[current_user.id])
            flash[:success] = "You are now part of this group"
            res.redirect "/groups/#{group.id}"
          rescue => e
            flash[:error] = "There was an error joining the group, please try again"
            res.redirect "/dashboard"
          end
        else
          not_found!
        end
      end

      session['fwc.join_group_code'] = code
      flash[:info] = "Please sign in first"
      res.redirect "/"
    end

    on current_user do
      run FunkyWorldCup::Groups
    end

    not_found!
  end

  on "cup-groups" do
    run FunkyWorldCup::CupGroups
  end

  on "users" do
    run FunkyWorldCup::Users

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

      on "rank" do
        @rank = UserScore.order(Sequel.desc(:score), :id).all
        res.write render("./views/layouts/application.html.erb") {
          render("./views/pages/rank.html.erb")
        }
      end

      not_found!
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

      if join_group_code = session.delete('fwc.join_group_code')
        if group = Group.find(link: join_group_code)
          begin
            GroupsUser.create(group_id: group.id, user_id: user.id)
            flash[:success] = "You are now part of group #{group.name}"
          rescue => e
            flash[:error] = "There was an error joining the group #{group.name}, please try again"
          end
        else
          flash[:error] = "There was an error joining the group #{group.name}, please try again"
        end
      end

      authenticate(user)

      res.redirect "/dashboard"
    end
  end
end
