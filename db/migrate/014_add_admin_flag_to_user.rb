Sequel.migration do
  up do
    alter_table(:users) do
      add_column :admin, 'boolean', default: false
    end
  end

  down do
    drop_column :users, :admin
  end
end
