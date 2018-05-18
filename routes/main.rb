module FunkyWorldCup
  class Main < Cuba
    settings[:render][:layout] = "layouts/application.html"

    define do
      on get do
        on "404" do
          not_found!
        end

        on "disclaimer" do
          res.write view("pages/disclaimer_#{session[:locale]}.html", {}, "layouts/home.html")
        end

        on "tos" do
          res.write view("pages/tos_#{session[:locale]}.html", {}, "layouts/home.html")
        end

        on "rules" do
          res.write view("pages/rules_#{session[:locale]}.html", {}, "layouts/home.html")
        end

        on "lang/:locale" do |locale|
          locale = locale.to_sym

          if FunkyWorldCup::ALLOWED_LOCALES.include? locale
            session[:locale] = locale
            current_user.update(:locale => locale) if current_user
          end

          res.redirect (req.env["HTTP_REFERER"].gsub(/lang=(es|en)\&?/, "") || "/")
        end

        on current_user do
          on root do
            res.redirect "/dashboard"
          end

          on "logout" do
            logout
          end

          on "dashboard" do
            winners = total_played = matches = nil

            session[:notifications] = current_user.get_and_read_notifications

            if FunkyWorldCup.finalized?
              winners      = UserScore.winners
              total_played = FunkyWorldCup.total_points
            else
              matches = Match.for_dashboard
            end

            map_hash = FunkyWorldCup::Map.new(CupGroup.all).series_data

            res.write view("pages/dashboard.html",
              matches:      matches,
              winners:      winners,
              total_played: total_played || 0,
              rank:         UserScore.rank_for(current_user.id),
              score:        current_user.score,
              params:       session.delete('fwc.contact_form') || {},
              map_hash:     map_hash,
            )
          end

          on "rank" do
            @user_rank ||= UserScore.rank_for(current_user.id)
            raw_rank   = UserScore.order(Sequel.desc(:score), :id).all
            key        = 0
            score      = 0
            @rank      = Hash.new

            raw_rank.each do |rank|
              if score.zero? || score > rank.score
                score = rank.score
                key += 1
              end
              @rank[key] = Array.new unless @rank.has_key?(key)
              @rank[key] << rank
            end

            res.write view("pages/rank.html")
          end

          not_found!
        end

        on root do
          res.write view("pages/home.html", {}, "layouts/home.html")
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
            user.update(:nickname => info['nickname'], :image => info['image'])
          end

          if join_group_code = session.delete('fwc.join_group_code')
            if group = Group.find(link: join_group_code)
              begin
                GroupsUser.create(group_id: group.id, user_id: user.id)
                flash[:success] = "#{I18n.t('.messages.groups.part_of')} #{group.name}"
              rescue
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

        on "dashboard" do
          res.redirect "/"
        end

        not_found!
      end

      not_found!
    end
  end
end
