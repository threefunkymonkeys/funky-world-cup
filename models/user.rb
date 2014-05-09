class User < Sequel::Model
  one_to_many :match_predictions
  many_to_many :groups, left_key: :user_id, right_key: :group_id, join_table: :groups_users

  def score
    MatchPrediction.where(user_id: id).sum(:prediction_score) || 0
  end

  def rank
    rank = 0
    UserScore.order(Sequel.desc(:score), :id).all.each_with_index do |position, index|
      rank = index + 1 if position.user_id == id
    end

    rank
  end

  def rank_in_group(group_id)
    rank = 0
    UserScore.join(:groups_users, user_id: :user_id, group_id: 20)
             .order(Sequel.desc(:score), Sequel.qualify(:user_scores, :id))
             .all
             .each_with_index do |position, index|
                rank = index + 1 if position.user_id == id
             end

    rank
  end

  def self.all_by_score
    User.all.sort { |a,b| b.score <=> a.score }
  end

  def after_create
    UserScore.create(user_id: id)
  end
end
