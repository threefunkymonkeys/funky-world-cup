Sequel.migration do
  up do
    create_table :match_penalties_predictions do
      primary_key :id
      foreign_key :user_id, :users
      foreign_key :match_id, :matches
      foreign_key :match_prediction_id, :match_predictions
      index [:user_id, :match_id, :match_prediction_id], unique: true
      Integer :host_score, default: 0
      Integer :rival_score, default: 0
      Integer :prediction_score, default: 0
    end
  end

  down do
    drop_table :match_penalties_predictions
  end
end

