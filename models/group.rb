class Group < Sequel::Model
  many_to_many :users, left_key: :group_id, right_key: :user_id, join_table: :groups_users

  many_to_one :user

  one_to_many :group_prizes, order: :order

  def participants
    GroupsUser.select(Sequel.qualify(:users, :id), :nickname, :score)
              .join(:users, id: :user_id)
              .left_join(:user_scores, user_id: :id)
              .where(group_id: id)
              .order(Sequel.desc(:score), Sequel.qualify(:groups_users, :id))
              .all
  end
end
