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
      TrueClass :show_rules, :default=>true
      String :locale, :text=>true

      index [:facebook_user]
      index [:twitter_user]
    end

    create_table(:group_positions) do
      primary_key :id
      foreign_key :group_id, :cup_groups, :key=>[:id]
      foreign_key :team_id, :teams, :type=>String, :text=>true, :key=>[:iso_code]
      Integer :won, :default=>0
      Integer :tied, :default=>0
      Integer :lost, :default=>0
      Integer :goals, :default=>0
      Integer :points, :default=>0
      Integer :received_goals, :default=>0
    end

    create_table(:groups) do
      primary_key :id
      foreign_key :user_id, :users, :key=>[:id]
      String :name, :text=>true, :null=>false
      String :description, :text=>true
      String :link, :text=>true
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

    create_table(:user_scores) do
      primary_key :id
      foreign_key :user_id, :users, :key=>[:id], :on_delete=>:cascade
      Integer :score, :default=>0
    end

    create_table(:group_prizes) do
      primary_key :id
      foreign_key :group_id, :groups, :key=>[:id], :on_delete=>:cascade
      String :name, :text=>true, :null=>false
      Integer :order, :null=>false
    end

    create_table(:groups_users, :ignore_index_errors=>true) do
      primary_key :id
      foreign_key :group_id, :groups, :key=>[:id], :on_delete=>:cascade
      foreign_key :user_id, :users, :key=>[:id]

      index [:group_id, :user_id], :unique=>true
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
