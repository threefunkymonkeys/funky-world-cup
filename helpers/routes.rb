module FunkyWorldCup::Helpers
  def not_found!
    res.status = 404
    res.write view("pages/404.html", {}, "layouts/home.html")

    halt res.finish
  end

  def no_content!
    res.headers.delete(Rack::CONTENT_TYPE)

    res.status = 204
    halt res.finish
  end

  def champion
    session[:champion] ||= FunkyWorldCup.champion
  end
end
