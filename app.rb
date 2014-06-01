require 'cuba'
require 'cuba/render'
require 'tilt/erb'
require 'sequel'
require "rack/protection"
require 'omniauth-twitter'
require 'omniauth-facebook'
require 'hatch'
require 'i18n'

require_relative 'helpers/environment'

ENV['RACK_ENV'] ||= :development

I18n.load_path += Dir['./locale/**/*.yml']
Encoding.default_internal, Encoding.default_external = ['utf-8'] * 2

FunkyWorldCup::Helpers.init_environment(ENV['RACK_ENV'])

Cuba.use Rack::Static,
          root: File.expand_path(File.dirname(__FILE__)) + "/public",
          urls: %w[/img /css /js]

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
Dir["./routes/**/*.rb"].each { |file| require file }
Dir["./validators/**/*.rb"].each { |file| require file }
Dir["./lib/**/*.rb"].each { |file| require file }

Cuba.plugin Cuba::Render
Cuba.plugin FunkyWorldCup::Helpers
Cuba.plugin FunkyWorldCup::Validators

include Cuba::Render::Helper

Cuba.define do
  init_locale(req.env)

  on "groups" do
    run FunkyWorldCup::Groups
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
      not_found!
    end

    on "disclaimer" do
      res.write render("./views/layouts/home.html.erb") {
        render("./views/pages/disclaimer_#{session[:locale]}.html")
      }
    end

    on "rules" do
      res.write render("./views/layouts/home.html.erb") {
        render("./views/pages/rules.html.erb")
      }
    end

    on "lang/:locale" do |locale|
      locale = locale.to_sym

      if FunkyWorldCup::ALLOWED_LOCALES.include? locale
        session[:locale] = locale
        current_user.update(:locale => locale) if current_user
      end

      res.redirect (req.env["HTTP_REFERER"] || "/")
    end

    on current_user do
      @user_rank ||= UserScore.rank_for(current_user.id)

      on root do
        res.redirect "/dashboard"
      end

      on "logout" do
        logout
      end

      on "dashboard" do
        if current_user.show_rules?
          current_user.update(:show_rules => false)
          res.write render("./views/layouts/application.html.erb") {
            render("./views/pages/first_view.html.erb")

          }
        else
          @matches = Match.for_dashboard.all
          res.write render("./views/layouts/application.html.erb") {
            render("./views/pages/dashboard.html.erb")
          }
        end
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
      else
        if (user.nickname != info['nickname'] || user.image != info['image'])
          user.update(:nickname => info['nickname'], :image => info['image'])
        end
      end

      if join_group_code = session.delete('fwc.join_group_code')
        if group = Group.find(link: join_group_code)
          begin
            GroupsUser.create(group_id: group.id, user_id: user.id)
            flash[:success] = "#{I18n.t('.messages.groups.part_of')} #{group.name}"
          rescue => e
            flash[:error] = "#{I18n.t('.messages.groups.cant_join')} #{group.name}, #{I18n.t('.messages.common.please')} #{I18n.t('.messages.common.try_again')}"
          end
        else
          flash[:error] = "#{I18n.t('.messages.groups.cant_join')} #{group.name}, #{I18n.t('.messages.common.please')} #{I18n.t('.messages.common.try_again')}"
        end
      end

      authenticate(user)

      res.redirect "/dashboard"
    end

    on "auth/failure" do
      flash[:error] = I18n.t(".errors.login_error")
      res.redirect "/"
    end
  end
end
