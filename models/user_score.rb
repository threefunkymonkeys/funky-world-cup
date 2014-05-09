class UserScore < Sequel::Model
  many_to_one :user, key: :user_id
end
