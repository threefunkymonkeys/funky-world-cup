module FunkyWorldCup::Helpers
  def not_found!
    res.status = 404
    res.write render("./views/layouts/home.html.erb") {
      render("./views/pages/404.html.erb")
    }
  end
end
