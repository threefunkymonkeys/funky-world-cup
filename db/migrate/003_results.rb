Sequel.migration do
  up do
    create_table :results do
      primary_key :id
      foreign_key :match_id, :matches
      Integer :host_score, default: 0
      Integer :rival_score, default: 0
      String  :status, default: 'partial'
    end
  end

  down do
    drop_table :results
  end
end
