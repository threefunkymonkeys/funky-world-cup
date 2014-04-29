class CupGroup < Sequel::Model

  one_to_many :matches, key: :group_id
end
