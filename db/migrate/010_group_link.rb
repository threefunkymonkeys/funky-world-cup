Sequel.migration do
  up do
    add_column :groups, :link, String, null: true
  end

  down do
    remove_column :groups, :link
  end
end
