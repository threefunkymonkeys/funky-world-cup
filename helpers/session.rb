module FunkyWorldCup
  module Helpers
    def authenticate(user)
      session[:user] = user
    end

    def logout
      session[:user] = nil
      res.redirect "/"
    end

    def current_user
      session[:user]
    end

    def user_authenticated?
      !session[:user].nil?
    end
  end
end
