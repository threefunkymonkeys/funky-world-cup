class Team < Sequel::Model
  one_to_many :matches, order: :start_datetime
end
