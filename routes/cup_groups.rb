module FunkyWorldCup
  class CupGroups < Cuba
    define do
      on get, "positions" do
        res.write render("./views/layouts/application.html.erb") {
          render("./views/cup_groups/positions.html.erb", groups: CupGroup.groups_phase.all)
        }
      end
    end
  end
end
