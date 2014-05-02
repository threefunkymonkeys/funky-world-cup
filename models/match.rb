class Match < Sequel::Model
  one_to_one :team, key: :host_id
  one_to_one :team, key: :rival_id

  one_to_one :result
  one_to_one :cup_group

  one_to_many :match_predictions
end
