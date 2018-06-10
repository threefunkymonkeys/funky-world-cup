require 'eventmachine'
require 'logger'
require 'net/http'
require 'nokogiri'
require './lib/twitter_notifier'
require "./app"

LOGGER= Logger.new('jobs/logs/update_results.log')

class UpdateResultsJob < BaseJob
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
      self.parse_livescore_matches(self.live_matches, Match.today_matches)
    rescue => e
      LOGGER.error("Failed to update results: #{e.message}")
    end
  end

  def self.live_matches
    livescores_url = "http://livescore-api.com/api-client/scores/live.json?key=#{ENV["LIVESCORE_API_KEY"]}&secret=#{ENV["LIVESCORE_API_SECRET"]}"
    results = JSON.parse(Net::HTTP.get_response(URI(livescores_url)).body)

    if results["success"] == true
      results["data"]["match"]
    else
      []
    end
  end

  def self.fix_names(page)
    page.gsub!(/Bosnia-Herzegovina/, "Bosnia and Herzegovina")
    page.gsub!(/South Korea/, "Korea Republic")
    page
  end

  def self.parse_livescore_matches(info_matches, today_matches)
    info_matches.each do |match|
      host_name = match["home_name"]
      rival_name = match["away_name"]
      score = match["score"].strip.split(" - ")

      is_final = match["status"] == "FINISHED"
      is_live = ["IN PLAY", "HALF TIME BREAK", "ADDED TIME", "INSUFFICIENT DATA"].include?(match["status"])

      had_extra_time = match["status"] == "EXTRA TIME"
      not_started = match["status"] == "NOT STARTED"

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
                  pk_score = "0 - 0".split(" - ") # We still need to figure this out with the new scores API
                  attrs[:host_penalties_score] = pk_score[0]
                  attrs[:rival_penalties_score] = pk_score[1]
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
