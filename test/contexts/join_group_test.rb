require File.expand_path(File.dirname(__FILE__)) + '/../test_helper'

describe 'JoinGroup context' do
  before do
    Group.dataset.destroy
    GroupsUser.dataset.destroy
    User.dataset.destroy
    @context = FunkyWorldCup::Groups.new
    @context.stubs(:session).returns({})
    @context.stubs(:flash).returns({})
  end

  describe 'with a valid group and user' do
    it 'should join the group' do
      user = User.spawn
      @context.stubs(:current_user).returns(user)
      group = Group.spawn(:user_id => User.spawn.id)
      FunkyWorldCup::JoinGroup.new(@context).execute(group).must_equal :success
    end

    it 'should not re-join a group' do
      user = User.spawn
      group = Group.spawn(:user_id => User.spawn.id)
      GroupsUser.create(:group_id => group.id, :user_id => user.id)
      @context.stubs(:current_user).returns(user)

      FunkyWorldCup::JoinGroup.new(@context).execute(group).must_equal :error
    end
  end

  describe 'without a valid group' do
    it 'should not find an invalid group' do
      group = nil
      FunkyWorldCup::JoinGroup.new(@context).execute(group).must_equal :not_found
    end
  end
end
