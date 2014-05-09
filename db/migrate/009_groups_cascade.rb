Sequel.migration do
  up do
    alter_table(:group_prizes) do
      drop_foreign_key [:group_id]
    end
    alter_table(:groups_users) do
      drop_foreign_key [:group_id]
    end
    alter_table(:group_prizes) do
      add_foreign_key [:group_id], :groups, on_delete: :cascade
    end
    alter_table(:groups_users) do
      add_foreign_key [:group_id], :groups, on_delete: :cascade
    end
  end

  down do
    alter_table(:group_prizes) do
      drop_foreign_key [:group_id]
    end
    alter_table(:groups_users) do
      drop_foreign_key [:group_id]
    end
    alter_table(:group_prizes) do
      add_foreign_key [:group_id], :groups
    end
    alter_table(:groups_users) do
      add_foreign_key [:group_id], :groups
    end
  end
end
