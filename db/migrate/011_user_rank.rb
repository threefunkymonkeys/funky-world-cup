Sequel.migration do
  up do
    create_table :user_scores do
      primary_key :id
      foreign_key :user_id, :users, on_delete: :cascade
      Integer :score, default: 0
    end
    add_index :user_scores, :score
  end

  down do
    drop_table :user_scores
  end
end
