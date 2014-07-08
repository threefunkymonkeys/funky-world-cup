class GroupPosition < Sequel::Model
  many_to_one :group_position, key: :group_id
  many_to_one :team,  key: :team_id

  def self.update_positions(match, result)
    host_team = GroupPosition.where(team_id: match.host_id).first
    host_team.update(
      goals: host_team.goals + result.host_score,
      received_goals: host_team.received_goals + result.rival_score,
      won: result.host_won? ? host_team.won + 1 : host_team.won,
      tied: result.draw? ? host_team.tied + 1 : host_team.tied,
      lost: result.rival_won? ? host_team.lost + 1 : host_team.lost,
      points: result.host_won? ? host_team.points + 3 : (result.draw? ? host_team.points + 1 : host_team.points)
    )
    rival_team = GroupPosition.where(team_id: match.rival_id).first
    rival_team.update(
      goals: rival_team.goals + result.rival_score,
      received_goals: rival_team.received_goals + result.host_score,
      won: result.rival_won? ? rival_team.won + 1 : rival_team.won,
      tied: result.draw? ? rival_team.tied + 1 : rival_team.tied,
      lost: result.host_won? ? rival_team.lost + 1 : rival_team.lost,
      points: result.rival_won? ? rival_team.points + 3 : (result.draw? ? rival_team.points + 1 : rival_team.points)
    )
  end

end
