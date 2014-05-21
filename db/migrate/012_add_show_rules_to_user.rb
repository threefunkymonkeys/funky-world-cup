Sequel.migration do
  up do
    alter_table(:users) do
      add_column :show_rules, "boolean", :default => true
    end
  end

  down do
    drop_column :users, :show_rules
  end
end
