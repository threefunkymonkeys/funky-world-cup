module FunkyWorldCup
  class CupGroups < Cuba
    settings[:render][:layout] = "layouts/application.html"

    define do
      on get, "positions" do
        res.write view(
          "cup_groups/positions.html",
          { groups: CupGroup.groups_phase.all },
          "layouts/application.html",
        )
      end

      on get, "fixture" do
        phases = CupGroup.fixture_matches
        groups = phases.delete("groups").group_by(&:name)

        res.write view("cup_groups/fixture.html",
          phases: phases,
          groups: groups
        )
      end

      not_found!
    end
  end
end
