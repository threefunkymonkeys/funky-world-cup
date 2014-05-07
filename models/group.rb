class Group < Sequel::Model
  many_to_many :users, left_key: :group_id, right_key: :user_id, join_table: :groups_users

  many_to_one :user

  def participants
    GroupsUser.select(:nickname)
              .select_append{ Sequel.as(sum(prediction_score), :score)}
              .join(:users, id: :user_id)
              .left_join(:match_predictions, user_id: :id)
              .where(group_id: id)
              .group_by(:nickname)
              .order(:score, :nickname)
              .all
  end
end
