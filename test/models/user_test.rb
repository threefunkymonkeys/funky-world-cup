require File.expand_path(File.dirname(__FILE__)) + '/../test_helper'

describe User do
  it 'should pick a nickname or return nil' do
    user = User.new

    user.nickname.must_equal nil

    user.twitter_user = 'twitter_man'

    user.nickname.must_equal user.twitter_user

    user.twitter_user = nil
    user.facebook_user = 'facebook_man'

    user.nickname.must_equal user.facebook_user
  end
end
