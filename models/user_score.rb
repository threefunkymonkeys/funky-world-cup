class UserScore < Sequel::Model
  many_to_one :user, key: :user_id

  def self.rank_for(user_id)
    rank = 0
    UserScore.order(Sequel.desc(:score), :id).all.each_with_index do |position, index|
      rank = index + 1 if position.user_id == user_id
    end

    rank
  end

  def self.update_scores(match, result)
    predictions = MatchPrediction.where(match_id: match.id).all
    predictions.each do |prediction|
      user_score = UserScore.where(user_id: prediction.user_id).first
      score = user_score.score + prediction.prediction_score
      if (result.host_score == result.rival_score) && result.match.allow_penalties? #ignore if cheating
        score += prediction.match_penalties_prediction.prediction_score unless prediction.match_penalties_prediction.nil?
      end
      user_score.update(score: score)
    end
  end
end
