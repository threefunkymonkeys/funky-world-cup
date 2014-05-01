class User < Sequel::Model
  def nickname
    twitter_user || facebook_user
  end
end
