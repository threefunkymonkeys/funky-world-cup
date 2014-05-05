class Match < Sequel::Model
  many_to_one :host_team,  class: :Team, key: :host_id
  many_to_one :rival_team, class: :Team, key: :rival_id

  one_to_one :result
  one_to_one :cup_group

  one_to_many :match_predictions

  def update_predictions_score
    match_predictions.each do |prediction|
      prediction.update_score(result)
    end
  end

  def finalized?
    result != nil && result.status == 'final'
  end
end
