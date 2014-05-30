require File.expand_path(File.dirname(__FILE__)) + '/../test_helper'

describe 'GroupCreate context' do
  before do
    Group.dataset.destroy
    GroupsUser.dataset.destroy
    User.dataset.destroy
    @user = User.spawn
    @context = FunkyWorldCup::Groups.new
    @context.stubs(:session).returns({})
    @context.stubs(:flash).returns({})
    @context.stubs(:current_user).returns(@user)
  end

  describe 'with valid attributes' do
    it 'should create group' do
      attrs = {'name' => 'Test Group', 'description' => 'Test Group Desc'}
      group = FunkyWorldCup::GroupCreate.new(@context).execute(attrs)

      group.name.must_equal attrs['name']
      group.description.must_equal attrs['description']
      group.user_id.must_equal @user.id
    end
  end

  describe 'with invalid attributes' do
    it 'should not create the group if missing required' do
      attrs = {'description' => 'Test Group Desc'}
      assert !FunkyWorldCup::GroupCreate.new(@context).execute(attrs)
    end

    it 'should not create a duplicated group' do
      attrs = {'name' => 'Test Group', 'description' => 'Test Group Desc'}
      group = Group.create(attrs.merge(:user_id => @user.id))
      
      assert !FunkyWorldCup::GroupCreate.new(@context).execute(attrs)
    end

  end
end
