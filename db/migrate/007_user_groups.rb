Sequel.migration do
  up do
    create_table :groups do
      primary_key :id
      String :name, null: false
      String :description
    end

    create_table :groups_users do
      primary_key :id
      foreign_key :group_id, :groups
      foreign_key :user_id, :users
      index [:group_id, :user_id], unique: true
    end
  end

  down do
    drop_table :groups
    drop_table :groups_users
  end
end
