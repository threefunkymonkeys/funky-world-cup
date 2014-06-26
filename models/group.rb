class Group < Sequel::Model
  many_to_many :users, left_key: :group_id, right_key: :user_id, join_table: :groups_users

  many_to_one :user

  one_to_many :group_prizes, order: :order

  def participants
    GroupsUser.select(Sequel.qualify(:users, :id), :nickname, :image, :score)
              .join(:users, id: :user_id)
              .left_join(:user_scores, user_id: :id)
              .where(group_id: id)
              .order(Sequel.desc(:score), Sequel.qualify(:user_scores, :id))
              .all
  end

  def rank_for(user_id)
    rank = 0
    last_rank = 0
    last_score = 0
    UserScore.join(:groups_users, user_id: :user_id, group_id: id)
             .order(Sequel.desc(:score), Sequel.qualify(:user_scores, :id))
             .all
             .each_with_index do |position, index|
                if last_score.zero? || position.score < last_score
                  last_score = position.score
                  last_rank += 1
                end
                rank = last_rank if position.user_id == user_id
             end

    rank
  end

end
