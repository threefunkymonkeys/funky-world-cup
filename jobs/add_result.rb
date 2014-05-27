require "./app"
require 'eventmachine'
require 'tzinfo'
require 'logger'

LOGGER= Logger.new('jobs/logs/add_result.log')

module ResultsJob
  def self.run
    Match.all.each do |match|
      next unless match.result.nil?
      tz = TZInfo::Timezone.get("Etc/#{match.local_timezone}")
      #In order to conform with the POSIX style, those zones beginning with "Etc/GMT" have their sign reversed from what most people expect. In this style, zones west of GMT have a positive sign and those east have a negative sign.
      local = tz.local_to_utc(Time.now.utc)

      if local >= match.start_datetime
        begin
          Result.create(match_id: match.id)
        rescue => e
          LOGGER.error e.message + " " + e.backtrace
        end
      end
    end
  end
end

Signal.trap("INT")  { EventMachine.stop }
Signal.trap("TERM") { EventMachine.stop }

EventMachine.run do
  timer = EventMachine::PeriodicTimer.new(ENV['ADD_RESULT_INTERVAL'] || 60) do
    LOGGER.info "running add_result job"
    ResultsJob.run
    if ENV['ADD_RESULT_ONE_RUN']
      timer.cancel
      EventMachine.stop
    end
  end
end

