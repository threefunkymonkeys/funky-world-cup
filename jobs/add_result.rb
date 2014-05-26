require_relative "../app"
require 'eventmachine'
require 'logger'

LOGGER= Logger.new('jobs/logs/add_result.log')

module ResultsJob
  def self.run
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

