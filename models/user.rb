class User < Sequel::Model
  one_to_many :match_predictions
end
