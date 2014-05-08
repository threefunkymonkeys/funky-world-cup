module FunkyWorldCup::Helpers
  def not_found!
    res.status = 404
    res.write "404"
  end
end
