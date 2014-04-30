Sequel.migration do
  up do
    create_table :teams do
      String :iso_code, primary_key: true
      String :name, null: false
      String :flag, null: false
    end

    create_table :cup_groups do
      primary_key :id
      String :name, null: false
      String :phase, default: 'groups'
    end
  end

  down do
    drop_table :teams
    drop_table :cup_groups
  end
end
