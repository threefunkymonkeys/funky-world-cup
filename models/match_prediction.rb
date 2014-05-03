class MatchPrediction < Sequel::Model
  one_to_one :match, key: :match_id
end
