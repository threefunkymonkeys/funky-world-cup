class User < Sequel::Model
  one_to_many :match_predictions
  many_to_many :groups, left_key: :user_id, right_key: :group_id, join_table: :groups_users

  def score
    MatchPrediction.where(user_id: id).sum(:prediction_score) || 0
  end

  def self.all_by_score
    User.all.sort { |a,b| b.score <=> a.score }
  end

  def after_create
    UserScore.create(user_id: id)
  end
end
