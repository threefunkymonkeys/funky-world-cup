module FunkyWorldCup
  class Admin < Cuba
    settings[:render][:layout] = "layouts/application.html"

    define do
      on current_user.nil? do
        not_found!
      end

      authenticate(User[current_user.id])

      on !current_user.admin do
        not_found!
      end

      on get, 'dashboard' do
        res.write view("admin/dashboard.html",
          users: User.count,
          groups: Group.count,
          predictions: MatchPrediction.count,
          matches: Match.where(start_datetime: (Time.now - 1*24*60*60)..(Time.now + 1*24*60*60)).all
        )
      end

      on 'matches/:id/edit' do |match_id|
        on match = Match[match_id] do
          on match.result && match.result.status == 'partial' do
            on get do
              res.write view("admin/match.html", match: match)
            end

            on put do
              begin
                req.params.delete('_method')
                req.params.delete('token')
                match.result.update(req.params)
                flash[:success] = I18n.t('.messages.matches.result_updated')
                res.redirect '/admin/dashboard'
              rescue => e
                message = I18n.t('.messages.matches.hook_error') if e.message == "the before_update hook failed"
                flash[:error] = "#{I18n.t('.messages.matches.cant_update')}. #{message || e.message}"
                res.redirect "/admin/matches/#{match.id}/edit"
              end
            end

            not_found!
          end

          not_found!
        end

        not_found!
      end

      not_found!
    end
  end
end
