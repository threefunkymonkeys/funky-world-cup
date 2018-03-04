Sequel.migration do
  up do
    alter_table(:matches) do
      drop_foreign_key :host_id
      add_foreign_key :host_id, :teams, type: String, on_delete: :cascade, on_update: :cascade

      drop_foreign_key :rival_id
      add_foreign_key :rival_id, :teams, type: String, on_delete: :cascade, on_update: :cascade

      drop_foreign_key :group_id
      add_foreign_key :group_id, :cup_groups, on_delete: :cascade, on_update: :cascade
    end

    alter_table(:results) do
      drop_foreign_key :match_id
      add_foreign_key :match_id, :matches, on_delete: :cascade, on_update: :cascade
    end

    alter_table(:match_penalties_predictions) do
      drop_foreign_key :user_id
      add_foreign_key :user_id, :users, on_delete: :cascade, on_update: :cascade

      drop_foreign_key :match_id
      add_foreign_key :match_id, :matches, on_delete: :cascade, on_update: :cascade

      drop_foreign_key :match_prediction_id
      add_foreign_key :match_prediction_id, :match_predictions, on_delete: :cascade, on_update: :cascade
    end

    alter_table(:user_notifications) do
      drop_foreign_key :user_id
      add_foreign_key :user_id, :users, on_delete: :cascade, on_update: :cascade

      drop_foreign_key :match_prediction_id
      add_foreign_key :match_prediction_id, :match_predictions, on_delete: :cascade, on_update: :cascade

      drop_foreign_key :match_penalties_prediction_id
      add_foreign_key :match_penalties_prediction_id, :match_predictions, on_delete: :cascade, on_update: :cascade
    end
  end
end
