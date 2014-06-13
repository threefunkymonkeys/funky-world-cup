module FunkyWorldCup
  class Teams < Cuba
    define do
      on current_user do
        calculate_user_rank

        on get, ':iso_code' do |iso_code|
          on team = Team[iso_code] do
            matches = Match.for_team(iso_code).all
            teams = Team.order(:name).all

            res.write render("./views/layouts/application.html.erb") {
              render("./views/teams/show.html.erb", matches: matches, team: team, teams: teams)
            }
          end

          not_found!
        end

        not_found!
      end

      on default do
        res.redirect "/"
      end
    end
  end
end
