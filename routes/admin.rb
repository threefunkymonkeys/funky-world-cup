module FunkyWorldCup
  class Admin < Cuba
    define do
      on current_user.nil? do
        not_found!
      end

      authenticate(User[current_user.id])

      on !current_user.admin do
        not_found!
      end

      on get, 'dashboard' do
        res.write render("./views/layouts/admin.html.erb") {
          render("./views/admin/dashboard.html.erb",
                 users: User.count,
                 groups: Group.count,
                 predictions: MatchPrediction.count,
                 matches: Match.where(start_datetime: (Time.now - 2*24*60*60)..(Time.now + 11*24*60*60)).all)
        }
      end

      on 'matches/:id/edit' do |match_id|
        on match = Match[match_id] do
          on match.result && match.result.status == 'partial' do
            on get do
              res.write render("./views/layouts/admin.html.erb") {
                render("./views/admin/match.html.erb", match: match)
              }
            end

            on put do
              begin
                req.params.delete('_method')
                match.result.update(req.params)
                flash[:success] = I18n.t('.messages.matches.result_updated')
                res.redirect '/admin/dashboard'
              rescue => e
                message = I18n.t('.messages.matches.hook_error') if e.message == "the before_update hook failed"
                flash[:error] = "#{I18n.t('.messages.matches.cant_update')}. #{message || ""}"
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
