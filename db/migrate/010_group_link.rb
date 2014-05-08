Sequel.migration do
  up do
    add_column :groups, :link, String, null: true
  end

  down do
    remoce_column :groups, :link
  end
end
