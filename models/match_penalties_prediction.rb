class MatchPenaltiesPrediction < Sequel::Model
  many_to_one :match, key: :match_id
end
