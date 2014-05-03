Sequel.migration do
  up do
    create_table :match_predictions do
      primary_key :id
      foreign_key :user_id
      foreign_key :match_id
      index [:user_id, :match_id], unique: true
      Integer :host_score, default: 0
      Integer :rival_score, default: 0
      Integer :prediction_score, default: 0
    end
  end

  down do
    drop_table :match_predictions
  end
end
