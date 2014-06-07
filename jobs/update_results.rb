require 'eventmachine'
require 'logger'
require 'net/http'
require 'nokogiri'
require "./app"

LOGGER= Logger.new('jobs/logs/update_results.log')

module UpdateResultsJob
  RESULTS_URL = 'http://www.livescore.com/worldcup2014/'

  def self.run
    page = self.fix_names(Net::HTTP.get_response(URI(RESULTS_URL)).body)

    #info_matches = self.parse_fifa_page(page)
    info_matches = self.parse_livescore_page(page)
    today_matches = Match.today_matches

    self.parse_livescore_matches(info_matches, today_matches)

  end

  def self.fix_names(page)
    page.gsub!(/Bosnia-Herzegovina/, "Bosnia and Herzegovina")
    page.gsub!(/South Korea/, "Korea Republic")
    page
  end

  def self.parse_livescore_page(page)
    doc = Nokogiri::HTML(page)
    #select all tr with a match inside, discard table header lines
    doc.css(".content .league-table tr").select { |node| node.css(".fh").any? }
  end

  def self.parse_livescore_matches(info_matches, today_matches)
    info_matches.each do |node|
      host_name = node.css(".fh").text.strip
      rival_name = node.css(".fa").text.strip
      score = node.css(".fs").text.strip.split(" - ")
      is_final = node.css(".fd").text.strip == "FT"
      is_live = node.css(".fd").text.strip == "HT" || node.css(".fd img").any?
      not_started = score[0] == "?" && score[1] == "?"

      today_matches.each do |match|
        if match.host_team.name.downcase == host_name.downcase &&
            match.rival_team.name.downcase == rival_name.downcase

          unless not_started
            status = is_live ? :partial : :final
            attrs = {:host_score => score[0],
                      :rival_score => score[1],
                      :status => status}

            if match.result.nil?
              match.result = Result.create(attrs)
            else
              match.result.update(attrs)
            end

            LOGGER.info({:match_id => match.id}.merge(attrs))
          end
        end
      end
    end
  end

end

Signal.trap("INT")  { EventMachine.stop }
Signal.trap("TERM") { EventMachine.stop }

EventMachine.run do
  timer = EventMachine::PeriodicTimer.new(ENV['UPDATE_RESULTS_INTERVAL'] || 300) do
    LOGGER.info "Updating Results..."
    UpdateResultsJob.run
  end
end

