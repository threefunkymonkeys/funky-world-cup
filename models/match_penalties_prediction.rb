class MatchPenaltiesPrediction < Sequel::Model
  many_to_one :match, key: :match_id

  def update_score(result)
    if host_score == result.host_penalties_score && rival_score == result.rival_penalties_score
      self.prediction_score = 3
      UserNotification.create(user_id: user_id, match_penalties_prediction_id: id, message: 'exact_match')
    elsif (host_score > rival_score && result.host_penalties_score > result.rival_penalties_score) ||
          (host_score < rival_score && result.host_penalties_score < result.rival_penalties_score)
      self.prediction_score = 1
      UserNotification.create(user_id: user_id, match_penalties_prediction_id: id, message: 'partial_match')
    end
    self.save unless self.prediction_score == 0
  end
end
