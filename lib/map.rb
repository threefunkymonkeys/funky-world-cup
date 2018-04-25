module FunkyWorldCup
  class Map
    COLORS_SCALE = ["#ff9059", "#7559ff", "#59ff90"].freeze

    SCALE = {
      "groups"         => 1,
      "16_round"       => 3,
      "quarter_finals" => 5,
      "semi_finals"    => 7,
      "third_place"    => 9,
      "final"          => 12,
      "champion"       => 20,
    }.freeze

    def initialize(cup_groups)
      @cup_groups = cup_groups
    end

    def series_data
      serie = {
        values:            {},
        scale:             COLORS_SCALE,
        normalizeFunction: "linear",
        min:               1,
        max:               20,
      }

      @cup_groups.each do |group|
        group.teams.each do |team|
          next unless team
          serie[:values][team.iso_code] = SCALE[group.phase]
        end

        if group.phase == "final"
          champion = group.matches.first.winner
          serie[:values][champion.iso_code] = SCALE["champion"] if champion
        end
      end

      serie
    end
  end
end
