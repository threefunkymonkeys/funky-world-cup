module FunkyWorldCup::Helpers
  def not_found!
    res.status = 404
    res.write render("./views/layouts/home.html.erb") {
      render("./views/pages/404.html.erb")
    }

    halt res.finish
  end

  def no_content!
    res.headers.delete(Rack::CONTENT_TYPE)

    res.status = 204
    halt res.finish
  end
end
