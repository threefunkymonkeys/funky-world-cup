require 'eventmachine'
require 'logger'
require 'net/http'
require 'nokogiri'
require './lib/twitter_notifier'
require "./app"

LOGGER= Logger.new('jobs/logs/update_results.log')

class UpdateResultsJob < BaseJob
  RESULTS_URL = 'http://www.livescore.com/worldcup2014/'
  @@tw_notifier = FunkyWorldCup::TwitterNotifier.new(
                    {:consumer_key => ENV["TWITTER_NOTIFY_KEY"],
                    :consumer_secret => ENV["TWITTER_NOTIFY_SECRET"],
                    :token => ENV["TWITTER_NOTIFY_TOKEN"],
                    :token_secret => ENV["TWITTER_NOTIFY_TOKEN_SECRET"]},
                    'jobs/logs/twitter_notifier.log'
                  )

  def self.interval
    ENV['UPDATE_RESULTS_INTERVAL'] || 60
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
      host_name = node.css(".fh").text.gsub(/\*/, "").strip
      rival_name = node.css(".fa").text.gsub(/\*/, "").strip
      score = node.css(".fs").text.strip.split(" - ")
      details_node = node.css(".fs a")
      match_details_link = details_node.any? ? details_node.attr("href").value : nil
      is_final = node.css(".fd").text.strip == "FT"
      is_live = node.css(".fd").text.strip == "HT" || node.css(".fd img").any?
      had_extra_time = node.css(".fd").text.strip == "AET"
      not_started = score[0] == "?" && score[1] == "?"

      today_matches.each do |match|
        next unless match.host_team && match.rival_team
        if match.host_team.name.downcase == host_name.downcase &&
            match.rival_team.name.downcase == rival_name.downcase

          unless not_started || (match.result && match.result.status == "final")
            status = is_live ? :partial : :final
            attrs = {:host_score => score[0],
                      :rival_score => score[1],
                      :status => status}

            if match.result.nil?
              match.result = Result.create(attrs)
              self.notify(match, :start)
            else
              if (match.result.host_score.to_s != attrs[:host_score].to_s ||
                       match.result.rival_score.to_s != attrs[:rival_score].to_s ||
                       match.result.status != attrs[:status].to_s)

                if status == :final && had_extra_time
                  details_doc = Nokogiri::HTML(Net::HTTP.get_response(URI("http://www.livescore.com" + match_details_link)).body)
                  result_details = details_doc.css(".content .fs div")

                  if result_details.length >= 3 #if less than 3 there wasn't any penalty kick and the result has been read
                    pk_score = result_details[2].text.strip.gsub(/\(|\)/, "").split(" - ")
                    attrs[:host_penalties_score] = pk_score[0]
                    attrs[:rival_penalties_score] = pk_score[1]
                  end
                end

                match.result.update(attrs)
                if match.result.status == "final"
                  self.notify(match, :finish)
                  FunkyWorldCup::PhaseUpdater.check(match)
                else
                  self.notify(match, :in_progress)
                end
              end
            end

            LOGGER.info({:match_id => match.id}.merge(attrs))
          end
        end
      end
    end
  end

  def self.notify(match, match_status)
    status = ["#{match.host_team.name} #{match.result.host_score}"]
    status << "#{match.result.rival_score} #{match.rival_team.name}"

    case match_status
    when :start
      status << "Start"
    when :in_progress
      status << "Live"
    when :finish
      status << "End"
    end

    notification = "#{status.join(" - ")} #BR2014 #Results #Resultados"

    @@tw_notifier.notify(notification)
  end
end
