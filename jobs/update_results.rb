require 'eventmachine'
require 'logger'
require 'net/http'
require 'nokogiri'
require "./app"

LOGGER= Logger.new('jobs/logs/update_results.log')

class UpdateResultsJob < BaseJob
  RESULTS_URL = 'http://www.livescore.com/worldcup2014/'

  def self.interval
    ENV['UPDATE_RESULTS_INTERVAL'] || 300
  end

  def self.message
    "Updating Results..."
  end

  def self.run
    begin
      page = self.fix_names(Net::HTTP.get_response(URI(RESULTS_URL)).body)

      info_matches = self.parse_livescore_page(page)
      today_matches = Match.today_matches

      self.parse_livescore_matches(info_matches, today_matches)
    rescue => e
      LOGGER.error("Failed to update results: #{e.message}")
    end
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
