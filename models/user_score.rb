class UserScore < Sequel::Model
  many_to_one :user, key: :user_id

  def self.rank_for(user_id)
    rank = 0
    last_rank = 0
    last_score = 0
    UserScore.order(Sequel.desc(:score), :id).all.each_with_index do |position, index|
      if last_score.zero? || position.score < last_score
        last_score = position.score
        last_rank += 1
      end
      rank = last_rank if position.user_id == user_id
    end

    rank
  end

  def self.update_scores(match, result)
    predictions = MatchPrediction.where(match_id: match.id).all
    predictions.each do |prediction|
      user_score = UserScore.where(user_id: prediction.user_id).first
      score = user_score.score + prediction.prediction_score
      if (result.host_score == result.rival_score) && (prediction.host_score == prediction.rival_score) && result.match.allow_penalties? #ignore if cheating
        score += prediction.match_penalties_prediction.prediction_score unless prediction.match_penalties_prediction.nil?
      end
      user_score.update(score: score)
    end
  end

  def self.winners
    raw_rank = UserScore.order(Sequel.desc(:score), :id).limit(15).all #more than 15 in the first 3 places?
    key = 0
    score = 0
    winners = Hash.new

    raw_rank.each do |rank|
      if score.zero? || score > rank.score
        score = rank.score
        key += 1
        break unless key <= 3
      end
      winners[key] = Array.new unless winners.has_key?(key)
      winners[key] << rank
    end

    winners
  end
end
