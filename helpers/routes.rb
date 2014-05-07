module FunkyWorldCup::Helpers
  def not_found!
    res.redirect "/404"
  end
end
