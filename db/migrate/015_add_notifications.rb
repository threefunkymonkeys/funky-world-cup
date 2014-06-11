Sequel.migration do
  up do
    create_table :user_notifications do
      primary_key :id
      foreign_key :user_id, :users
      foreign_key :match_prediction_id, :match_predictions
      String :message
      Boolean :read, default: false

    end
    add_index :user_notifications, :read
  end

  down do
    drop_table :user_notifications
  end
end
