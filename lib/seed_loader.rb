require 'yaml'

class SeedLoader

  def initialize(file = 'db/seeds/worldcup_2014.yml')
    @cup_data = YAML.load_file(file)['worldcup']
  end

  def seed
    seed_teams(@cup_data['teams'])
    seed_groups(@cup_data['groups_phase'])
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
          puts "Team #{code} created"
        rescue => e
          puts "Team #{code} not loaded. Error: #{e.message}"
        end
      end
      Team.restrict_primary_key
    end

    def seed_groups(groups)
      groups.each do |name, group|
        begin
          DB.transaction do
            cup_group = CupGroup.create(name: name)
            group['matches'].each do |match|
              Match.create(
                host_id: match['host'],
                rival_id: match['rival'],
                group_id: cup_group.id,
                start_datetime: DateTime.parse(match['date']),
                place: match['place'],
                stadium: match['stadium'],
                local_timezone: match['local_timezone']
              )
            end
          end
        rescue => e
          puts "Group: #{name} not loaded. Error: #{e.message}"
        end
      end
    end
end
