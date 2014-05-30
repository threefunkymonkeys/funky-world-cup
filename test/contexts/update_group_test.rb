require File.expand_path(File.dirname(__FILE__)) + '/../test_helper'

describe 'GroupUpdate context' do
  before do
    Group.dataset.destroy
    User.dataset.destroy
    @user = User.spawn
    @context = FunkyWorldCup::Groups.new
    @context.stubs(:session).returns({})
    @context.stubs(:flash).returns({})
    @context.stubs(:current_user).returns(@user)
  end

  describe 'with valid attributes' do
    it 'should update group' do
      attrs = {'name' => 'Test Group', 'description' => 'Test Group Desc'}
      group = Group.spawn(attrs.merge(:user_id => @user.id))

      attrs['name'] = "Updated"

      assert FunkyWorldCup::GroupUpdate.new(@context, group).execute(attrs)

      group.reload.name.must_equal attrs['name']
    end
  end

  describe 'with invalid attributes' do
    it 'should not update the group if missing required' do
      attrs = {'name' => 'Test Group', 'description' => 'Test Group Desc'}
      group = Group.spawn(attrs.merge(:user_id => @user.id))

      attrs.delete('name')

      assert !FunkyWorldCup::GroupUpdate.new(@context, group).execute(attrs)

      group.reload.name.must_equal 'Test Group'
    end

    it 'should not allow a duplicated name' do
      attrs = {'name' => 'Test Group', 'description' => 'Test Group Desc'}
      Group.create(attrs.merge(:user_id => @user.id))
      attrs = {'name' => 'Other Group', 'description' => 'Test Group Desc'}
      group = Group.create(attrs.merge(:user_id => @user.id))

      attrs['name'] = "Test Group"
      
      assert !FunkyWorldCup::GroupUpdate.new(@context, group).execute(attrs)
    end
  end
end
