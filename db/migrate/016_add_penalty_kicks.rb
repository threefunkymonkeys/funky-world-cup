Sequel.migration do
  up do
    alter_table(:results) do
      add_column :host_penalties_score, Integer, default: 0
      add_column :rival_penalties_score, Integer, default: 0
    end
  end

  down do
    drop_column :users, :host_penalties_score
    drop_column :users, :rival_penalties_score
  end
end
