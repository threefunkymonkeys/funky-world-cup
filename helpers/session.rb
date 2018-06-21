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

    def flash
      session['fwc.flash'] = (@env['rack.session']['fwc.flash'] || {})
      session['fwc.flash']
    end

    def calculate_user_rank
      res.redirect "/" unless current_user
      @user_rank ||= UserScore.rank_for(current_user.id)
    end

    def check_session
      unless user_authenticated?
        session['fwc.return_to'] = req.path
        res.redirect "/"
        halt res.finish
      end
    end
  end
end
