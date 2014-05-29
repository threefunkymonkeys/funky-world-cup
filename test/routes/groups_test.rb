require File.expand_path(File.dirname(__FILE__)) + '/../test_helper'
include FunkyWorldCup::Helpers
require 'mocha/mini_test'
require 'pry-debugger'

describe 'Users Groups' do
  before do
    Group.dataset.destroy
    User.dataset.destroy
    GroupPrize.dataset.destroy
  end

  describe 'when logged in' do
    before do
      @user ||= User.spawn
      FunkyWorldCup::Groups.any_instance.stubs(:current_user).returns(@user)
    end

    it 'should allow creation' do
      group_name = "Test Group"
      post '/groups', :group => {:name => group_name}

      group = Group.find(:name => group_name)
      group.wont_be_nil
      group.user_id.must_equal @user.id
    end

    it "should list current user's groups" do
      groups = [Group.spawn(:user_id => @user.id),
                Group.spawn(:user_id => @user.id)]

      groups.each do |group|
        GroupsUser.create(:user_id => @user.id, :group_id => group.id)
      end

      response = get '/groups'
      response.status.must_equal 200

      response.body.must_include groups.first.name
      response.body.must_include groups.last.name
    end

    it "should show details" do
      group = Group.spawn(:user_id => @user.id)
      GroupsUser.create(:user_id => @user.id, :group_id => group.id)
      prize = GroupPrize.create(:group_id => group.id,
                                :name => "Test Prize",
                                :order => 1)

      response = get "/groups/#{group.id}"

      response.status.must_equal 200
      response.body.must_include group.name
      response.body.must_include @user.nickname
      response.body.must_include prize.name
    end

    it "should allow edition" do
      group = Group.spawn(:user_id => @user.id)
      GroupsUser.create(:user_id => @user.id, :group_id => group.id)

      response = get "/groups/#{group.id}/edit"
      response.status.must_equal 200

      put "/groups/#{group.id}", :group => {:name => "Name", :description => "Description"}

      group.reload
      group.name.must_equal "Name"
      group.description.must_equal "Description"
    end

    it "should allow deletion" do
      group = Group.spawn(:user_id => @user.id)
      GroupsUser.create(:user_id => @user.id, :group_id => group.id)

      response = delete "/groups/#{group.id}"
      Group[group.id].must_be_nil
    end

    it "should allow join" do
      another_user = User.spawn
      group = Group.spawn(:user_id => another_user.id, :link => "test-group-link")

      get "/groups/join/test-group-link"
      @user.groups.must_include group
    end

    describe 'when the user owns a group' do
      before do
      end

      it 'should show edit page' do
        group = Group.spawn(:user_id => @user.id)

        response = get "/groups/#{group.id}/edit"
        response.status.must_equal 200
      end

      it 'should show the prizes page' do
        group = Group.spawn(:user_id => @user.id)

        response = get "/groups/#{group.id}/prizes"
        response.status.must_equal 200
      end
    end

    describe "when the user doesn\'t own the group" do
      it 'should not find the edit page' do
        group = Group.spawn
        response = get "/groups/#{group.id}/edit"

        response.status.must_equal 404
      end

      it 'should not find the prizes page' do
        group = Group.spawn
        response = get "/groups/#{group.id}/prizes"

        response.status.must_equal 404
      end
    end
  end

  describe 'when logged out' do
    it 'should not allow creation' do
      group_name = "Test Group"
      response = post '/groups', :group => {:name => group_name}

      response.status.must_equal 404
      Group.find(:name => group_name).must_be_nil
    end

    it 'should not allow update' do
      group = Group.spawn(:name => "Test Group")
      response = put "/groups/#{group.id}", :group => {:name => "Other"}

      response.status.must_equal 404
      group.reload.name.must_equal "Test Group"
    end

    it 'should be not found' do
      response = get '/groups'
      response.status.must_equal 404
    end

    it 'should not allow deletion' do
      group = Group.spawn

      response = delete "/groups/#{group.id}"
      response.status.must_equal 404
      Group[group.id].wont_be_nil
    end

    it "should be redirected to sign in" do
      another_user = User.spawn
      group = Group.spawn(:user_id => another_user.id, :link => "test-group-link")

      response = get "/groups/join/test-group-link"

      response.status.must_equal 302
      response.location.must_equal "/"
    end
  end
end
