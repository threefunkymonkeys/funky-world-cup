module FunkyWorldCup
  def self.finalized?
    match = last_match
    match && !match.result.nil? && match.result.status == 'final'
  end

  def self.total_points
    total_points = 0
    results = Result.where(status: "final")

    results.each do |result|
      total_points += 3
      total_points += 3 if result.match.cup_group.phase != "groups" && result.host_score == result.rival_score
    end

    total_points
  end

  def self.champion
    finalized? ? last_match.winner : nil
  end

  protected
    def self.last_match
      final = CupGroup.where(phase: 'final').last
      final.matches.last
    end
end
