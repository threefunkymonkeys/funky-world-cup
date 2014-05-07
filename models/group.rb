class Group < Sequel::Model
  many_to_many :users, left_key: :group_id, right_key: :user_id, join_table: :groups_users

  many_to_one :user
end
