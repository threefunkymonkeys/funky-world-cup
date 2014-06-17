class MatchPrediction < Sequel::Model
  many_to_one :match, key: :match_id
  one_to_one :match_penalties_prediction, key: :match_prediction_id

  def update_score(result)
    if host_score == result.host_score && rival_score == result.rival_score
      self.prediction_score = 3
      UserNotification.create(user_id: user_id, match_prediction_id: id, message: 'exact_match')
    elsif (host_score > rival_score && result.host_score > result.rival_score) ||
          (host_score < rival_score && result.host_score < result.rival_score) ||
          (host_score == rival_score && result.host_score == result.rival_score)
      self.prediction_score = 1
      UserNotification.create(user_id: user_id, match_prediction_id: id, message: 'partial_match')
    end
    self.save unless self.prediction_score == 0
  end

  def self.prediction_for(user_id, match_id)
    MatchPrediction.where(user_id: user_id, match_id: match_id).first
  end
end
