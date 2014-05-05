require File.expand_path(File.dirname(__FILE__)) + '/../test_helper'

describe 'Score' do
  def setup
    User.all.each { |user| user.delete }
    MatchPrediction.all.each { |predictions| predictions.delete }
    Result.all.each { |result| result.delete }
  end

  it 'should update user score on exact prediction' do
    match = Match.all.sample
    user = User.spawn
    prediction = MatchPrediction.spawn(user_id: user.id, match_id: match.id)
    match.result = Result.spawn(host_score: prediction.host_score, rival_score: prediction.rival_score)

    assert_equal 0, prediction.prediction_score
    assert_equal 0, user.score

    match.result.status = 'final'
    match.result.save

    prediction.reload

    assert_equal 3, prediction.prediction_score
    assert_equal 3, user.score
  end

  it 'should update user score on non-exact prediction' do
    match = Match.all.sample
    user = User.spawn
    prediction = MatchPrediction.spawn(user_id: user.id, match_id: match.id)
    match.result = Result.spawn(host_score: prediction.host_score + 1, rival_score: prediction.rival_score + 1)

    assert_equal 0, prediction.prediction_score
    assert_equal 0, user.score

    match.result.status = 'final'
    match.result.save

    prediction.reload

    assert_equal 1, prediction.prediction_score
    assert_equal 1, user.score
  end

  it 'should not update user score on wrong prediction' do
    match = Match.all.sample
    user = User.spawn
    prediction = MatchPrediction.spawn(user_id: user.id, match_id: match.id, host_score: 1, rival_score: 1)
    match.result = Result.spawn(host_score: prediction.host_score, rival_score: prediction.rival_score + 1)

    assert_equal 0, prediction.prediction_score
    assert_equal 0, user.score

    match.result.status = 'final'
    match.result.save

    prediction.reload

    assert_equal 0, prediction.prediction_score
    assert_equal 0, user.score
  end
end
