Sequel.migration do
  up do
    create_table :group_prizes do
      primary_key :id
      foreign_key :group_id, :groups
      String :name, null: false
      Integer :order, null: false
    end
  end

  down do
    drop_table :group_prizes
  end
end
