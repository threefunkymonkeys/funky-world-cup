Sequel.migration do
  up do
    create_table :teams do
      primary_key :iso_code
      String :name, null: false
      String :flag, null: false
    end

  end

  down do
    drop_table :teams
  end
end
