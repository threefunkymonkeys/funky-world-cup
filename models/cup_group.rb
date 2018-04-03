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
    sql =<<-EOF
      WITH group_dates AS (
        SELECT DATE(MIN(start_datetime)) AS group_start,
          DATE(MAX(start_datetime)) AS group_end,
          DATE(NOW()) as today,
          group_id
        FROM matches
        GROUP BY group_id
      )
      SELECT group_dates.*, cup_groups.name, cup_groups.phase
      FROM group_dates
      INNER JOIN cup_groups ON cup_groups.id = group_dates.group_id
      WHERE today BETWEEN group_start AND group_end
    EOF

    results = FunkyWorldCup::Helpers.database.fetch(sql).all

    if results.empty?
      CupGroup.find(:phase => self.next_stage)
    else
      CupGroup[results.first[:group_id]]
    end
  end

  def self.fixture_matches
    CupGroup.join(:matches, group_id: :id).order(:start_datetime).to_hash_groups(:phase)
  end

  private

  def self.next_stage
    sql =<<-EOF
      WITH groups_dates AS (
        SELECT DATE(MIN(start_datetime)) AS group_start_date, group_id
        FROM matches
        GROUP BY group_id
      )
      SELECT groups_dates.*, cup_groups.phase
      FROM groups_dates
      INNER JOIN cup_groups ON cup_groups.id = groups_dates.group_id
      WHERE DATE(NOW()) < group_start_date
      ORDER BY group_start_date
      LIMIT 1;
    EOF

    results = FunkyWorldCup::Helpers.database.fetch(sql).all

    if results.any?
      results.first[:phase]
    else
      "final"
    end
  end
end
