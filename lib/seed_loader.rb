require 'yaml'

class SeedLoader

  def initialize(file = 'db/seeds/worldcup_2014.yml')
    @cup_data = YAML.load_file(file)['worldcup']
  end

  def seed(empty = true)
    if empty
      Result.dataset.delete
      Match.dataset.delete
      Team.dataset.delete
      CupGroup.dataset.delete
    end

    seed_teams(@cup_data['teams'])
    seed_groups_phase(@cup_data['groups_phase'])
    seed_round_of_16(@cup_data['16_round']['matches'])
    seed_quarter_finals(@cup_data['quarter_finals']['matches'])
    seed_semi_finals(@cup_data['semi_finals']['matches'])
    seed_final(@cup_data['final']['matches'])
    seed_third_place(@cup_data['third_place']['matches'])
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

    def seed_groups_phase(groups)
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
          puts "Group: #{name} created"
        rescue => e
          puts "Group: #{name} not loaded. Error: #{e.message}"
        end
      end
    end

    def seed_round_of_16(matches)
      seed_single_group('Round of 16', matches)
    end

    def seed_quarter_finals(matches)
      seed_single_group('Quarter-Finals', matches)
    end

    def seed_semi_finals(matches)
      seed_single_group('Semi-Finals', matches)
    end

    def seed_final(matches)
      seed_single_group('Final', matches)
    end

    def seed_third_place(matches)
      seed_single_group('Play-Off for Third Place', matches)
    end

    def seed_single_group(name, matches)
      begin
        DB.transaction do
          group = CupGroup.create(name: name)
          matches.each do |match|
            Match.create(
              host_description: match['host_description'],
              rival_description: match['rival_description'],
              host_code: match['host_code'],
              rival_code: match['rival_code'],
              group_id: group.id,
              start_datetime: DateTime.parse(match['date']),
              place: match['place'],
              stadium: match['stadium'],
              local_timezone: match['local_timezone']
            )
          end
          puts "Group: #{name} created"
        end
      rescue => e
        puts "Group: #{name} not loaded. Error: #{e.message}"
      end
    end
end
