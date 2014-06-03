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

      not_found!
    end
  end
end
