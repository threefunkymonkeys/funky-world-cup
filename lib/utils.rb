module FunkyWorldCup
  def self.finalized?
    match = last_match
    match && !match.result.nil? && match.result.status == 'final'
  end

  def self.total_points
    total = Match.count * 3
    total += CupGroup.where(phase:'groups').invert.inner_join(Match, matches__group_id: :id).inner_join(Result, results__match_id: :matches__id).where(host_score: :rival_score).count * 3
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
