class Match < Sequel::Model
  many_to_one :host_team,  class: :Team, key: :host_id
  many_to_one :rival_team, class: :Team, key: :rival_id

  one_to_one :result
  many_to_one :cup_group, key: :group_id

  one_to_many :match_predictions

  def update_predictions_score
    match_predictions.each do |prediction|
      prediction.update_score(result)
      if (result.host_score == result.rival_score) && (prediction.host_score == prediction.rival_score) && result.match.allow_penalties? #ignore if cheating
        prediction.match_penalties_prediction.update_score(result) unless prediction.match_penalties_prediction.nil?
      end
    end
  end

  def finalized?
    result != nil && result.status == 'final'
  end

  def winner
    if finalized?
      if result.host_score > result.rival_score || result.host_penalties_score > result.rival_penalties_score
        return self.host_team
      elsif result.host_score < result.rival_score || result.host_penalties_score < result.rival_penalties_score
        return self.rival_team
      end
    end
  end

  def loser
    if finalized?
      if result.host_score < result.rival_score || result.host_penalties_score < result.rival_penalties_score
        return self.host_team
      elsif result.host_score > result.rival_score || result.host_penalties_score > result.rival_penalties_score
        return self.rival_team
      end
    end
  end

  def draw?
    finalized? && result.host_score == result.rival_score
  end

  def allow_penalties?
    cup_group.phase != 'groups'
  end

  def predictable?
    host_team && rival_team && result.nil?
  end

  def self.for_dashboard
    group = CupGroup.now_playing

    if group.phase == "groups"
      start_date = min(:start_datetime).to_date

      if Date.today < start_date #WC hasn't started yet
        date = start_date
      else
        date = Date.today
      end

      @@dashboard_matches = select_all(:matches).
                              select_append(:cup_groups__name).
                              join(:cup_groups, :id => :group_id).
                              where("cup_groups.phase LIKE 'groups' AND DATE(matches.start_datetime) BETWEEN ? AND ?", date - 1, date + 1).
                              order(:start_datetime)

    elsif group.phase == "final" || group.phase == "third_place"
      ids = CupGroup.select(:id).where(:phase => ["final", "third_place"]).map(&:id)
      @@dashboard_matches = Match.select_all(:matches).
                                  select_append(:cup_groups__name).
                                  where(:group_id => ids).
                                  join(:cup_groups, :id => :group_id).
                                  order(:start_datetime)

    else
      @@dashboard_matches = Match.select_all(:matches).
                                  select_append(:cup_groups__name).
                                  where(:group_id => group.id).
                                  join(:cup_groups, :id => :group_id).
                                  order(:start_datetime)
    end
  end

  def self.today_matches
    Match.where("DATE(start_datetime) BETWEEN ?  AND ?",  Date.today - 1, Date.today + 1)
  end

  def self.for_team(iso_code)
    select_all(:matches).select_append(:cup_groups__name).join(:cup_groups, :id => :group_id).where(host_id: iso_code).or(rival_id: iso_code).order(:start_datetime)
  end
end
