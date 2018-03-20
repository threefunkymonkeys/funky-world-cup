module FunkyWorldCup
  class CupGroups < Cuba
    define do
      calculate_user_rank

      on get, "positions" do
        res.write render("./views/layouts/application.html.erb") {
          render("./views/cup_groups/positions.html.erb", groups: CupGroup.groups_phase.all)
        }
      end

      on get, "fixture" do
        res.write render("./views/layouts/application_2014.html.erb") {
          render("./views/cup_groups/fixture.html.erb", fixture: CupGroup.join(:matches, group_id: :id).order(:start_datetime).to_hash_groups(:phase) )
        }
      end

      not_found!
    end
  end
end
