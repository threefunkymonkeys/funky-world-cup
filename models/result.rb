class Result < Sequel::Model
  many_to_one :match

  def before_update
    old = Result[id]
    return false if old.status == 'final' && status != 'final'
    match.update_score if old.status == 'partial' && status == 'final'
  end
end
