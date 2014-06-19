class UserNotification < Sequel::Model
  many_to_one :match_prediction
  many_to_one :match_penalties_prediction
end
