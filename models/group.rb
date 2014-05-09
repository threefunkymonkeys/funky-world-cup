class Group < Sequel::Model
  many_to_many :users, left_key: :group_id, right_key: :user_id, join_table: :groups_users

  many_to_one :user

  one_to_many :group_prizes, order: :order

  def participants
    GroupsUser.select(Sequel.qualify(:users, :id), :nickname)
              .select_append{ Sequel.as(sum(prediction_score), :score)}
              .join(:users, id: :user_id)
              .left_join(:match_predictions, user_id: :id)
              .where(group_id: id)
              .group_by(:nickname, Sequel.qualify(:users, :id))
              .order(:score, :nickname)
              .all
  end
end
