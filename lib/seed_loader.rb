require 'yaml'

class SeedLoader

  def initialize(file = 'db/seeds/worldcup_2014.yml')
    @cup_data = YAML.load_file(file)
  end

  def seed
    seed_teams(@cup_data['worldcup']['teams'])
  end

  private

    def seed_teams(teams)
      Team.unrestrict_primary_key
      teams.each do |code, hash|
        begin
          Team.create(
            iso_code: code,
            name: hash['name'],
            flag: hash['flag']
          )
        rescue => e
          puts "#{code} not loaded. Error: #{e.message}"
        end
      end
      Team.restrict_primary_key
    end
end
