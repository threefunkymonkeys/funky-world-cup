Sequel.migration do
  change do
    create_table(:schema_info) do
      Integer :version, :default=>0, :null=>false
    end

    create_table(:teams) do
      primary_key :iso_code
      String :name, :text=>true, :null=>false
      String :flag, :text=>true, :null=>false
    end

    create_table(:matches) do
      primary_key :id
      foreign_key :host_id, :teams, :key=>[:iso_code]
      foreign_key :rival_id, :teams, :key=>[:iso_code]
      DateTime :start_datetime, :null=>false
      String :place, :text=>true, :null=>false
      String :stadium, :text=>true, :null=>false
      String :local_timezone, :text=>true, :null=>false
      String :host_description, :text=>true
      String :rival_description, :text=>true
    end

    create_table(:results) do
      primary_key :id
      foreign_key :match_id, :matches, :key=>[:id]
      Integer :host_score, :default=>0
      Integer :rival_score, :default=>0
      String :status, :default=>"partial", :text=>true
    end
  end
end
