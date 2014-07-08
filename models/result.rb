class Result < Sequel::Model
  many_to_one :match

  def before_update
    old = Result[id]
    return false if old.status == 'final' && status != 'final'
    if old.status == 'partial' && status == 'final'
      match.update_predictions_score
      GroupPosition.update_positions(match, self) if match.cup_group.phase == 'groups'
      UserScore.update_scores(match, self)
    end
  end

  def host_won?
    host_score > rival_score
  end

  def rival_won?
    rival_score > host_score
  end

  def draw?
    rival_score == host_score
  end
end
