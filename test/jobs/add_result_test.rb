require File.expand_path(File.dirname(__FILE__)) + '/../test_helper'
require 'tzinfo'

describe "ResultsJob" do
  def setup
    Result.all.each { |result| result.delete }
  end

  it 'should add result to match' do
    tz = TZInfo::Timezone.get('Etc/GMT-3')
    group = CupGroup.create(name: 'Test')
    match = Match.create(
      host_id: 'MX',
      rival_id: 'BR',
      group_id: group.id,
      place: 'test',
      stadium: 'test',
      local_timezone: 'GMT-3',
      start_datetime: tz.local_to_utc(Time.now)
    )

    assert_equal nil, match.result

    ENV['ADD_RESULT_ONE_RUN'] = "1"
    ENV['ADD_RESULT_INTERVAL'] = "1"
    require_relative "../../jobs/add_result.rb"

    match.reload

    assert_equal false, match.result.nil?
    assert_equal 'partial', match.result.status
    assert_equal 0, match.result.host_score
    assert_equal 0, match.result.rival_score
  end

  it 'should not add result to match when it already have a result' do
    tz = TZInfo::Timezone.get('Etc/GMT-3')
    group = CupGroup.create(name: 'Test')
    match = Match.create(
      host_id: 'MX',
      rival_id: 'BR',
      group_id: group.id,
      place: 'test',
      stadium: 'test',
      local_timezone: 'GMT-3',
      start_datetime: tz.local_to_utc(Time.now)
    )
    Result.create(match_id: match.id)
    match.reload

    assert_equal false, match.result.nil?

    ENV['ADD_RESULT_ONE_RUN'] = "1"
    ENV['ADD_RESULT_INTERVAL'] = "1"
    require_relative "../../jobs/add_result.rb"

    assert_equal 1, Result.where(match_id: match.id).count
  end
end
