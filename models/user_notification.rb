class UserNotification < Sequel::Model
  many_to_one :match_prediction
end
