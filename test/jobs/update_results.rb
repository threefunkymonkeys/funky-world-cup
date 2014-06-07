require File.expand_path(File.dirname(__FILE__)) + '/../test_helper'
require './jobs/update_results'

describe 'UpdateResultsJob' do
  BASE_DIR = File.expand_path(File.dirname(__FILE__))
  def setup
    GroupPosition.dataset.destroy
    Result.dataset.destroy
    Match.dataset.destroy
    Team.dataset.destroy
    Team.unrestrict_primary_key
  end

  def teardown
    Team.unrestrict_primary_key
  end

  it 'should create partial result if Half Time' do
    response = OpenStruct.new(:body => File.read("#{BASE_DIR}/matches/br_hr_partial.html"))

    Net::HTTP.stubs(:get_response).returns(response)

    home = Team.create(:iso_code => "BR", :name => "Brazil", :flag => "br_flag.png")
    away = Team.create(:iso_code => "HR", :name => "Croatia", :flag => "hr_flag.png")
    match = Match.spawn(:host_id => home.iso_code, :rival_id => away.iso_code)

    UpdateResultsJob.run

    match.result.host_score.must_equal 0
    match.result.rival_score.must_equal 1
    match.result.status.must_equal "partial"
  end

  it 'should create partial result if live' do
    response = OpenStruct.new(:body => File.read("#{BASE_DIR}/matches/ar_bs_live.html"))

    Net::HTTP.stubs(:get_response).returns(response)

    home = Team.create(:iso_code => "AR", :name => "Argentina", :flag => "ar_flag.png")
    away = Team.create(:iso_code => "BH", :name => "Bosnia And Herzegovina", :flag => "bh_flag.png")
    match = Match.spawn(:host_id => home.iso_code, :rival_id => away.iso_code)
    Result.create(:match_id => match.id, :host_score => 0, :rival_score => 0)

    UpdateResultsJob.run

    match.result.host_score.must_equal 0
    match.result.rival_score.must_equal 0
    match.result.status.must_equal "partial"
  end

  it 'should add final result' do
    response = OpenStruct.new(:body => File.read("#{BASE_DIR}/matches/es_nl_final.html"))

    Net::HTTP.stubs(:get_response).returns(response)

    home = Team.create(:iso_code => "ES", :name => "Spain", :flag => "br_flag.png")
    away = Team.create(:iso_code => "NL", :name => "Netherlands", :flag => "hr_flag.png")
    match = Match.spawn(:host_id => home.iso_code, :rival_id => away.iso_code)

    UpdateResultsJob.run

    match.result.host_score.must_equal 1
    match.result.rival_score.must_equal 2
    match.result.status.must_equal "final"
  end
end

