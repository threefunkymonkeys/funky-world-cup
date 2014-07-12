Sequel.migration do
  up do
    create_table :user_contacts do
      primary_key :id
      foreign_key :user_id, :users
      String :email, null: false
      String :address, null: false
      String :post_code, null: false
      String :city, null: false
      String :state, null: false
      String :country, null: false
      String :comment, null: false
    end
  end

  down do
    drop_table :user_contacts
  end
end
