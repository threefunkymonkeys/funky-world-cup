class CupGroup < Sequel::Model
  one_to_many :matches, key: :group_id
  one_to_many :group_positions, key: :group_id

  def teams
    matches.map { |match| [match.host_team, match.rival_team] }.flatten.uniq
  end

  def positions
    GroupPosition.select.select_append{ Sequel.as(goals - received_goals, :diff)}.where(group_id: id).order(:points, :diff).all
  end
end
