module FunkyWorldCup
  def self.finalized?
    final = CupGroup.where(phase: 'final').last
    match = final.matches.last

    !match.result.nil? && match.result.status == 'final'
  end

  def self.total_points
    total = Match.count * 3
    total += CupGroup.where(phase:'groups').invert.inner_join(Match, matches__group_id: :id).inner_join(Result, results__match_id: :matches__id).where(host_score: :rival_score).count * 3
  end
end
