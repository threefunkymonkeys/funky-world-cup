module FunkyWorldCup
  class CupGroups < Cuba
    define do
      on get, "positions" do
        res.write view(
          "cup_groups/positions.html",
          { groups: CupGroup.groups_phase.all },
          "layouts/application.html",
        )
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
