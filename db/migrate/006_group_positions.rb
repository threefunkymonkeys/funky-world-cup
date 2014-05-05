Sequel.migration do
  up do
    create_table :group_positions do
      primary_key :id
      foreign_key :group_id, :cup_groups
      foreign_key :team_id, :teams, type: String
      Integer :won,    default: 0
      Integer :tied,   default: 0
      Integer :lost,   default: 0
      Integer :goals,  default: 0
      Integer :points, default: 0
      Integer :received_goals, default: 0
    end
  end

  down do
    drop_table :group_positions
  end
end
