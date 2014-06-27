class CupGroup < Sequel::Model
  one_to_many :matches, key: :group_id
  one_to_many :group_positions, key: :group_id

  subset(:groups_phase, :phase => "groups")

  def teams
    matches.map { |match| [match.host_team, match.rival_team] }.flatten.uniq
  end

  def positions_table
    GroupPosition.select.select_append{ Sequel.as(goals - received_goals, :diff)}.where(group_id: id).order(Sequel.desc(:points), Sequel.desc(:diff), Sequel.desc(:goals)).all
  end

  def matches_table
    Match.where(group_id: id).order(:start_datetime).all
  end

  def self.now_playing
    sql = 'WITH group_dates AS (SELECT DATE(MIN(start_datetime)) AS group_start, DATE(MAX(start_datetime)) AS group_end, DATE(NOW()) as today, group_id FROM matches GROUP BY group_id) SELECT group_dates.*, cup_groups.name, cup_groups.phase FROM group_dates INNER JOIN cup_groups ON cup_groups.id = group_dates.group_id WHERE today BETWEEN group_start AND group_end'

    results = FunkyWorldCup::Helpers.database.fetch(sql).all

    if results.empty?
      CupGroup.find(:phase => "16_round")
    else
      CupGroup[results.first[:group_id]]
    end
  end
end
