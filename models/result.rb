class Result < Sequel::Model
  one_to_one :matches
end
