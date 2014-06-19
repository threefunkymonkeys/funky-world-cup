module FunkyWorldCup
  class PhaseUpdater
    def self.check(match)
      return unless match.winner

      case match.cup_group.phase
      when "groups"
        total_matches = Match.where(:group_id => match.group_id)
        finished_matches = Match.where(:group_id => match.group_id, :status => "final").join(:results, :match_id => :id)

        if total_matches.count != finished_matches.count
          self.fill_round_of_sixteen_for(match.cup_group)
        end
      when "round_16"
        self.find_quarter_finals_for(match)
      when "quarter_finals"
        self.find_semi_finals_for(match)
      when "semi_finals"
        self.find_final_games_for(match)
      end
    end

    def self.fill_round_of_sixteen_for(cup_group)
      first, second = cup_group.positions_table[0,2]
      match = Match.find(:host_code => "#{cup_group.name}:1")

      raise RuntimeError.new("Invalid Match for host") unless match

      match.update(:host_id => first.team_id)

      match = Match.find(:host_code => "#{cup_group.name}:2")

      raise RuntimeError.new("Invalid Match for rival") unless match

      match.update(:rival_id => second.team_id)
    end

    def self.find_quarter_finals_for(match)
      match_index = self.find_match_index(match)

      raise RuntimeError.new("Invalid match for quarter finals") unless match_index

      match_index += 1
      group = CupGroup.find(:phase => "quarter_finals")

      qf_match = Match.find(:group_id => group.id, :host_code => match_index.to_s)
      winner = match.winner

      if qf_match
        qf_match.update(:host_id => winner.iso_code)
      elsif qf_match = Match.find(:group_id => group.id, :rival_code => match_index.to_s)
        qf_match.update(:rival_id => winner.iso_code)
      else
        raise RuntimeError.new("No quarter final match found")
      end
    end

    def self.find_semi_finals_for(match)
      match_index = self.find_match_index(match)

      raise RuntimeError.new("Invalid match for semi finals") unless match_index

      match_index += 1
      group = CupGroup.find(:phase => "semi_finals")

      sf_match = Match.find(:group_id => group.id, :host_code => match_index.to_s)
      winner = match.winner

      if sf_match
        sf_match.update(:host_id => winner.iso_code)
      elsif sf_match = Match.find(:group_id => group.id, :rival_code => match_index.to_s)
        sf_match.update(:rival_id => winner.iso_code)
      else
        raise RuntimeError.new("No semi final match found")
      end
    end

    def self.find_final_games_for(match)
      match_index = self.find_match_index(match)

      raise RuntimeError.new("Invalid match for finals") unless match_index

      match_index += 1

      final_group = CupGroup.find(:phase => "final")
      third_group = CupGroup.find(:phase => "third_place")

      if match_index == 1
        final_group.matches.first.update(:host_id => match.winner)
        third_group.matches.first.update(:host_id => match.loser)
      elsif match_index == 2
        final_group.matches.first.update(:rival_id => match.winner)
        third_group.matches.first.update(:rival_id => match.loser)
      else
        raise RuntimeError.new("Invalid semi final match")
      end
    end

    private
    def self.find_match_index(match)
      Match.where(:group_id => match.group_id).order(:start_datetime).map(&:id).index(match.id)
    end
  end
end
