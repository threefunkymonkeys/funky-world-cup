class User < Sequel::Model
  one_to_many :match_predictions

  def score
    MatchPrediction.where(user_id: id).sum(:prediction_score) || 0
  end

  def self.all_by_score
    User.all.sort { |a,b| b.score <=> a.score }
  end
end
