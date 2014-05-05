User.extend(Spawn).spawner do |user|
  user.name  = Faker::Name.name
  user.nickname = Faker::Internet.user_name
end

MatchPrediction.extend(Spawn).spawner do |prediction|
  prediction.host_score = (0..9).to_a.sample
  prediction.rival_score = (0..9).to_a.sample
end

Result.extend(Spawn).spawner do |result|
  result.host_score = (0..9).to_a.sample
  result.rival_score = (0..9).to_a.sample
  result.status = 'partial'
end
