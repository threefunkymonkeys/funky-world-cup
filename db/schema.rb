Sequel.migration do
  change do
    create_table(:cup_groups) do
      primary_key :id
      String :name, :text=>true, :null=>false
      String :phase, :default=>"groups", :text=>true
    end

    create_table(:match_predictions, :ignore_index_errors=>true) do
      primary_key :id
      Integer :user_id
      Integer :match_id
      Integer :host_score, :default=>0
      Integer :rival_score, :default=>0
      Integer :prediction_score, :default=>0

      index [:user_id, :match_id], :unique=>true
    end

    create_table(:schema_info) do
      Integer :version, :default=>0, :null=>false
    end

    create_table(:teams) do
      String :iso_code, :text=>true, :null=>false
      String :name, :text=>true, :null=>false
      String :flag, :text=>true, :null=>false

      primary_key [:iso_code]
    end

    create_table(:users, :ignore_index_errors=>true) do
      primary_key :id
      String :name, :text=>true
      String :nickname, :text=>true
      String :twitter_user, :text=>true
      String :facebook_user, :text=>true
      String :image, :text=>true

      index [:facebook_user]
      index [:twitter_user]
    end

    create_table(:matches) do
      primary_key :id
      foreign_key :host_id, :teams, :type=>String, :text=>true, :key=>[:iso_code]
      foreign_key :rival_id, :teams, :type=>String, :text=>true, :key=>[:iso_code]
      foreign_key :group_id, :cup_groups, :key=>[:id]
      DateTime :start_datetime, :null=>false
      String :place, :text=>true, :null=>false
      String :stadium, :text=>true, :null=>false
      String :local_timezone, :text=>true, :null=>false
      String :host_description, :text=>true
      String :rival_description, :text=>true
      String :host_code, :text=>true
      String :rival_code, :text=>true
      TrueClass :enabled, :default=>true
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
