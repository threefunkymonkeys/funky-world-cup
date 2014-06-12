module FunkyWorldCup
  class Teams < Cuba
    define do
      calculate_user_rank

      on get, ':iso_code' do |iso_code|
        on team = Team[iso_code] do
          matches = Match.for_team(iso_code).all
          res.write render("./views/layouts/application.html.erb") {
            render("./views/teams/show.html.erb", matches: matches, team: team)
          }
        end

        not_found!
      end

      not_found!
    end
  end
end
