class GroupPosition < Sequel::Model
  many_to_one :group_position, key: :group_id
  many_to_one :team,  key: :team_id
end
