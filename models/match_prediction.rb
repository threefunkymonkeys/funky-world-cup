class MatchPrediction < Sequel::Model
  many_to_one :match

  def update_score(result)
    if host_score == result.host_score && rival_score == result.rival_score
      self.prediction_score = 3
    elsif (host_score > rival_score && result.host_score > result.rival_score) ||
          (host_score < rival_score && result.host_score < result.rival_score) ||
          (host_score == rival_score && result.host_score == result.rival_score)
      self.prediction_score = 1
    end
    self.save unless self.prediction_score == 0
  end
end
