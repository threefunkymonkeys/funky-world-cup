require "./app"
require 'eventmachine'
require 'tzinfo'
require 'logger'
require './lib/twitter_notifier'

LOGGER= Logger.new('jobs/logs/add_result.log')

class AddResultJob < BaseJob
  @@tw_notifier = FunkyWorldCup::TwitterNotifier.new(
                    {:consumer_key => ENV["TWITTER_NOTIFY_KEY"],
                    :consumer_secret => ENV["TWITTER_NOTIFY_SECRET"],
                    :token => ENV["TWITTER_NOTIFY_TOKEN"],
                    :token_secret => ENV["TWITTER_NOTIFY_TOKEN_SECRET"]},
                    'jobs/logs/twitter_notifier.log'
                  )

  def self.interval
    ENV['ADD_RESULT_INTERVAL'] || 60
  end

  def self.one_run_only
    ENV.has_key?('ADD_RESULT_ONE_RUN')
  end

  def self.message
    "Adding initial result..."
  end

  def self.run
    Match.all.each do |match|
      next unless match.result.nil?
      tz = TZInfo::Timezone.get("Etc/#{match.local_timezone}")
      #In order to conform with the POSIX style, those zones beginning with "Etc/GMT" have their sign reversed from what most people expect. In this style, zones west of GMT have a positive sign and those east have a negative sign.
      local = tz.local_to_utc(Time.now.utc)

      if local >= match.start_datetime
        begin
          Result.create(match_id: match.id)
          notification = "#{match.host_team.name} 0 - 0 #{match.rival_team.name} - Start #BR2014 #Results #Resultados"

          @@tw_notifier.notify(notification)
        rescue => e
          LOGGER.error e.message + " " + e.backtrace
        end
      end
    end
  end
end
