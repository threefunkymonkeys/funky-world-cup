Sequel.migration do
  up do
    alter_table(:user_notifications) do
      add_foreign_key :match_penalties_prediction_id, :match_penalties_predictions
    end
  end

  down do
    drop_column :user_notifications, :match_penalties_prediction_id
  end
end

