module FunkyWorldCup
  class Users < Cuba
    define do
      on post do
        on current_user do
          on :id do |user_id|

            on "predictions" do
              not_found unless root

              params = req.params
              match = Match[params['match_id'].to_i]
              if match.result.nil?
                unless MatchPrediction.where(match_id: params['match_id'].to_i, user_id: current_user.id).any?
                  begin
                    MatchPrediction.create(
                      user_id:     current_user.id,
                      match_id:    params['match_id'].to_i,
                      host_score:  params['host_score'].to_i,
                      rival_score: params['rival_score'].to_i
                    )
                    flash[:success] = "Your prediction was added"
                  rescue => e
                    flash[:error] = "There was an error adding the prediction for this match, please try again"
                  end
                else
                  flash[:error] = "Trying to cheat? You can't"
                end
              else
                flash[:error] = "You can not longer add a prediction for this match"
              end
              res.redirect "/#{params.has_key?('back_to') ? params['back_to'] : "dashboard"}#match-#{match.id}"
            end

            not_found!
          end

          not_found!
        end

        not_found!
      end
    end
  end
end
