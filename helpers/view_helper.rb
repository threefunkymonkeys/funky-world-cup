class Cuba
  module Render::Helper
    def show_flash_message
      markup = []

      if flash.has_key?(:info)
        markup << "<div class='alert alert-dismissable alert-info'><button type='button' class='close' data-dismiss='alert'>×</button>" +
            "#{flash[:info]}</div>"
        flash.delete(:info)
      end

      if flash.has_key?(:success)
        markup << "<div class='alert alert-dismissable alert-success'><button type='button' class='close' data-dismiss='alert'>×</button>" +
            "#{flash[:success]}</div>"
        flash.delete(:success)
      end

      if flash.has_key?(:warning)
        markup << "<div class='alert alert-dismissable alert-warning'><button type='button' class='close' data-dismiss='alert'>×</button>" +
            "#{flash[:warning]}</div>"
        flash.delete(:warning)
      end

      if flash.has_key?(:error)
        markup << "<div class='alert alert-dismissable alert-danger'><button type='button' class='close' data-dismiss='alert'>×</button>" +
            "#{flash[:error]}</div>"
        flash.delete(:error)
      end

      markup.join("<br/>")
    end

    def class_for_index(index)
     case index
      when 0, 1
        'success'
      when 2
        'warning'
      else
        'danger'
      end
    end

    def class_for_path(path)
      'active' if path == req.path
    end
  end
end
