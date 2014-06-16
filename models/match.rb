class Match < Sequel::Model
  many_to_one :host_team,  class: :Team, key: :host_id
  many_to_one :rival_team, class: :Team, key: :rival_id

  one_to_one :result
  many_to_one :cup_group, key: :group_id

  one_to_many :match_predictions

  def update_predictions_score
    match_predictions.each do |prediction|
      prediction.update_score(result)
    end
  end

  def finalized?
    result != nil && result.status == 'final'
  end

  def self.for_dashboard
    @@dashboard_matches ||= lambda {
      start_date = min(:start_datetime).to_date

      if Date.today < start_date #WC hasn't started yet
        date = start_date
      else
        date = Date.today
      end

      select_all(:matches).select_append(:cup_groups__name).join(:cup_groups, :id => :group_id).where("cup_groups.phase LIKE 'groups' AND DATE(matches.start_datetime) BETWEEN ? AND ?", date - 1, date + 1).order(:start_datetime)
    }.call
  end

  def self.today_matches
    Match.where("DATE(start_datetime) BETWEEN ?  AND ?",  Date.today - 1, Date.today + 1)
  end

  def self.for_team(iso_code)
    select_all(:matches).select_append(:cup_groups__name).join(:cup_groups, :id => :group_id).where(host_id: iso_code).or(rival_id: iso_code).order(:start_datetime)
  end
end
