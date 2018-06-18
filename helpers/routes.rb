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

  def respond_json(body, status = 200)
    res["Content-type"] = "application/json;encoding=utf8"
    res.status = status

    res.write body.to_json

    halt res.finish
  end
end
