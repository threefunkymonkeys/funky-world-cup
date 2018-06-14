Sequel.migration do
  up do
    alter_table(:users) do
      add_column :last_seen, "integer"
    end
  end

  down do
    drop_column :users, :last_seen
  end
end
