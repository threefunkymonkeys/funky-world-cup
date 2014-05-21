module FunkyWorldCup
  class CupGroups < Cuba
    define do
      @user_rank ||= UserScore.rank_for(current_user.id)

      on get, "positions" do
        res.write render("./views/layouts/application.html.erb") {
          render("./views/cup_groups/positions.html.erb", groups: CupGroup.groups_phase.all)
        }
      end

      on get, "fixture" do
        res.write render("./views/layouts/application.html.erb") {
          render("./views/cup_groups/fixture.html.erb", fixture: CupGroup.join(:matches, group_id: :id).to_hash_groups(:phase) )
        }
      end

      not_found!
    end
  end
end
