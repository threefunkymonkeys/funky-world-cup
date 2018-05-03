module FunkyWorldCup
  class Teams < Cuba
    settings[:render][:layout] = "layouts/application.html"

    define do
      on current_user do
        on get, ':iso_code' do |iso_code|
          on team = Team[iso_code] do
            matches = Match.for_team(iso_code).all
            teams = Team.order(:name).all

            res.write view("teams/show.html", matches: matches, team: team, teams: teams)
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
