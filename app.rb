require 'cuba'
require 'cuba/render'

Cuba.use Rack::Static,
          root: File.expand_path(File.dirname(__FILE__)) + "/public",
          urls: %w[/img /css /js]

Cuba.plugin Cuba::Render

Cuba.define do
  on get do
    on root do
      res.write render("./views/layouts/home.html.erb") {
        render("./views/pages/home.html.erb")
      }
    end
  end
end
