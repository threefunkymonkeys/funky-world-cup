Sequel.migration do
  up do
    alter_table(:users) do
      add_column :locale, String
    end
  end

  down do
    drop_column :users, :locale
  end
end
