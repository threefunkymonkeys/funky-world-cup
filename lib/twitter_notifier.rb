require 'simple_oauth'
require 'net/http'

module FunkyWorldCup
  class TwitterNotifier
    @@url = "https://api.twitter.com/1.1/statuses/update.json"

    def initialize(oauth_settings = {}, log_file = STDOUT)
      @oauth_settings = oauth_settings
      @logger = Logger.new(log_file)
    end

    def notify(status)
      raise RuntimeError.new("Status too long") if status.length > 140

      header  = SimpleOAuth::Header.new("POST", @@url, {status: status}, @oauth_settings)
      body    = URI.encode("status=#{status}")
      uri     = URI(@@url)
      request = create_request_for(uri.path, header, body)

      Net::HTTP.start(uri.host, uri.port, :use_ssl => true) do |http|
        response = http.request request

        if response.code.to_s == "200"
          @logger.info("Success")
        else
          @logger.error("#{response.code} - #{response.body}")
        end
      end
    end

    private
    def create_request_for(path, header, body)

      request = Net::HTTP::Post.new(path)  

      request.body = body
      request["Accept"]         = "*/*"
      request["Connection"]     = "close"
      request["User-Agent"]     = "FunkyWorldCup Notifier 0.1"
      request["Content-Type"]   = "application/x-www-form-urlencoded"
      request["Authorization"]  = header.to_s
      request["Content-Length"] = body.length
      request["Host"]           = "api.twitter.com"
      request
    end
  end
end
