require File.expand_path(File.dirname(__FILE__)) + '/../test_helper'

describe 'Match' do

  describe 'for dashboard' do
    SeedLoader.new(false).seed

    it 'should return groups matches if groups stage' do
      group = CupGroup.find(:phase => "groups")
      today = Date.parse("2014-06-15")

      CupGroup.stubs(:now_playing).returns(group)
      Date.stubs(:today).returns(today)

      dashboard_matches = Match.for_dashboard

      dashboard_matches.each do |match|
        match.cup_group.phase.must_equal "groups"
      end
    end

    it 'should retrurn 16 round matches when on 16 round stage' do
      group = CupGroup.find(:phase => "16_round")
      today = Date.parse("2014-06-28")

      CupGroup.stubs(:now_playing).returns(group)
      Date.stubs(:today).returns(today)

      dashboard_matches = Match.for_dashboard

      dashboard_matches.each do |match|
        match.cup_group.phase.must_equal "16_round"
      end
    end

    it 'should return quarter final matches if quarter finals' do
      group = CupGroup.find(:phase => "quarter_finals")
      today = Date.parse("2014-07-04")

      CupGroup.stubs(:now_playing).returns(group)
      Date.stubs(:today).returns(today)

      dashboard_matches = Match.for_dashboard

      dashboard_matches.each do |match|
        match.cup_group.phase.must_equal "quarter_finals"
      end
    end

    it 'should return semi final matches if semi finals' do
      group = CupGroup.find(:phase => "semi_finals")
      today = Date.parse("2014-07-08")

      CupGroup.stubs(:now_playing).returns(group)
      Date.stubs(:today).returns(today)

      dashboard_matches = Match.for_dashboard

      dashboard_matches.each do |match|
        match.cup_group.phase.must_equal "semi_finals"
      end
    end

    it 'should return final matches if finals' do
      group = CupGroup.find(:phase => "final")
      today = Date.parse("2014-07-08")

      CupGroup.stubs(:now_playing).returns(group)
      Date.stubs(:today).returns(today)

      dashboard_matches = Match.for_dashboard

      phases = dashboard_matches.map(&:cup_group).map(&:phase)

      phases.must_include "final"
      phases.must_include "third_place"
    end
  end
end
