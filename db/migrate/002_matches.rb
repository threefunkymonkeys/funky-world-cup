Sequel.migration do
  up do
    create_table :matches do
      primary_key :id
      foreign_key :host_id,  :teams, type: String
      foreign_key :rival_id, :teams, type: String
      foreign_key :group_id, :cup_groups
      DateTime :start_datetime, null: false
      String   :place, null: false
      String   :stadium, null: false
      String   :local_timezone, null: false
      String   :host_description
      String   :rival_description
      Boolean  :enabled, default: true
    end
  end

  down do
    drop_table :matches
  end
end
