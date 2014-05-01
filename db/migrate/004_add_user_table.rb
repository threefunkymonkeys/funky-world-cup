Sequel.migration do
  up do
    create_table :users do
      primary_key :id
      String :name, :null => true
      String :nickname, :null => true
      String :twitter_user, :null => true
      String :facebook_user, :null => true
      String :image, :null => true
    end

    add_index :users, :twitter_user
    add_index :users, :facebook_user
  end

  down do
    drop_table :users
  end
end
