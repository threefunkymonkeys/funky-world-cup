class Cuba
  module Render::Helper
    BR_HTML_TAG = "<br>".freeze

    def show_flash_message
      [].tap { |markup|
        [:info, :success, :warning, :error].each do |flash_key|
          if flash.key?(flash_key)
            markup << partial("shared/_flash_message.html", klass: flash_key, message: flash[flash_key])
            flash.delete(flash_key)
          end
        end
      }.join(BR_HTML_TAG)
    end

    def show_notifications
      if session[:notifications] && session[:notifications].any?
        partial("shared/_notifications.html", notifications: session.delete(:notifications))
      end
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
      'active' if req.path =~ /\A#{path}/
    end

    def translate_description(description)
      rank, part = description.downcase.split(" of ")
      part.gsub!("group", I18n.t('.common.group')) if part.include? "group"
      rank = I18n.t(".common.#{rank}_of")
      "#{rank} #{part}"
    end

    def prizes_to_vue_json(prizes)
      prizes.map(&:to_hash).to_json
    end
  end
end
