module FunkyWorldCup::Validators
  class GroupForm
    include Hatch

    certify('name', "Name can not be empty") do |name|
      !name.nil? && !name.empty?
    end
  end
end
