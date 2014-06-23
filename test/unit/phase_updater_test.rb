require File.expand_path(File.dirname(__FILE__)) + '/../test_helper'

describe 'PhaseUpdater' do
  def setup
    SeedLoader.new(false).seed
  end

  it 'should fill 16th round matches' do
    a_group = CupGroup.find(:name => "A")
    b_group = CupGroup.find(:name => "B")

    a_group.matches.each do |match|
      match.result = Result.create(
        :host_score => rand(0..4),
        :rival_score => rand(0..4),
        :status => "final"
      )
      GroupPosition.update_positions(match, match.result)
    end

    b_group.matches.each do |match|
      match.result = Result.create(
        :host_score => rand(0..4),
        :rival_score => rand(0..4),
        :status => "final"
      )
      GroupPosition.update_positions(match, match.result)
    end

    a_first, a_second = a_group.positions_table[0,2]
    b_first, b_second = b_group.positions_table[0,2]

    FunkyWorldCup::PhaseUpdater.check(a_group.matches.last)
    FunkyWorldCup::PhaseUpdater.check(b_group.matches.last)

    first_of_a_match = Match.find(:host_code => "A:1")
    first_of_b_match = Match.find(:host_code => "B:1")

    #binding.pry

    first_of_a_match.host_team.iso_code.must_equal a_first.team_id
    first_of_a_match.rival_team.iso_code.must_equal b_second.team_id

    first_of_b_match.host_team.iso_code.must_equal b_first.team_id
    first_of_b_match.rival_team.iso_code.must_equal a_second.team_id
  end

  it 'should fill quarter finals matches' do
    group = CupGroup.find(:phase => "16_round")
    matches = Match.where(:group_id => group.id).order(:start_datetime).all
    teams = Team.all

    matches.each do|match|
      match.update(:host_id => teams.sample.iso_code, :rival_id => teams.sample.iso_code)
      match.result = Result.create(:host_score => 2, :rival_score => 1, :status => "final")
      FunkyWorldCup::PhaseUpdater.check(match)
    end

    qf_group = CupGroup.find(:phase => "quarter_finals")

    qf_match = Match.find(:group_id => qf_group.id, :host_code => "1")
    qf_match.host_team.iso_code.must_equal matches[0].winner.iso_code
    qf_match.rival_team.iso_code.must_equal matches[1].winner.iso_code

    qf_match = Match.find(:group_id => qf_group.id, :host_code => "3")
    qf_match.host_team.iso_code.must_equal matches[2].winner.iso_code
    qf_match.rival_team.iso_code.must_equal matches[3].winner.iso_code

    qf_match = Match.find(:group_id => qf_group.id, :host_code => "5")
    qf_match.host_team.iso_code.must_equal matches[4].winner.iso_code
    qf_match.rival_team.iso_code.must_equal matches[5].winner.iso_code

    qf_match = Match.find(:group_id => qf_group.id, :host_code => "7")
    qf_match.host_team.iso_code.must_equal matches[6].winner.iso_code
    qf_match.rival_team.iso_code.must_equal matches[7].winner.iso_code
  end

  it 'should fill semi finals matches' do
    group = CupGroup.find(:phase => "quarter_finals")
    matches = Match.where(:group_id => group.id).order(:start_datetime).all
    teams = Team.all

    matches.each do |match|
      match.update(:host_id => teams.sample.iso_code, :rival_id => teams.sample.iso_code)
      match.result = Result.create(:host_score => 2, :rival_score => 1, :status => "final")
      FunkyWorldCup::PhaseUpdater.check(match)
    end

    sf_group = CupGroup.find(:phase => "semi_finals")

    sf_match = Match.find(:group_id => sf_group.id, :host_code => "1")
    sf_match.host_team.iso_code.must_equal matches[0].winner.iso_code
    sf_match.rival_team.iso_code.must_equal matches[1].winner.iso_code

    sf_match = Match.find(:group_id => sf_group.id, :host_code => "3")
    sf_match.host_team.iso_code.must_equal matches[2].winner.iso_code
    sf_match.rival_team.iso_code.must_equal matches[3].winner.iso_code
  end

  it 'should fill final matches' do
    group = CupGroup.find(:phase => "semi_finals")
    matches = Match.where(:group_id => group.id).order(:start_datetime).all
    teams = Team.all

    matches.each do |match|
      match.update(:host_id => teams.sample.iso_code, :rival_id => teams.sample.iso_code)
      match.result = Result.create(:host_score => 2, :rival_score => 1, :status => "final")
      FunkyWorldCup::PhaseUpdater.check(match)
    end

    fn_group = CupGroup.find(:phase => "final")
    tp_group = CupGroup.find(:phase => "third_place")

    fn_match = Match.find(:group_id => fn_group.id)
    tp_match = Match.find(:group_id => tp_group.id)

    fn_match.host_team.iso_code.must_equal matches[0].winner.iso_code
    fn_match.rival_team.iso_code.must_equal matches[1].winner.iso_code
    tp_match.host_team.iso_code.must_equal matches[0].loser.iso_code
    tp_match.rival_team.iso_code.must_equal matches[1].loser.iso_code
  end
end
