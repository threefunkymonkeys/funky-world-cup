module FunkyWorldCup
  class Users < Cuba
    define do
      on get do
        on current_user do
          on :id do |user_id|

            on "predictions" do
              not_found unless root

              res.write render("./views/layouts/application.html.erb") {
                render("./views/users/predictions.html.erb", predictions: MatchPrediction.where(user_id: user_id).all)
              }
            end

            not_found!
          end

          not_found!
        end

        not_found!
      end

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
                    flash[:success] = I18n.t('.messages.matches.prediction_added')
                  rescue => e
                    flash[:error] = "#{I18n.t('.messages.matches.cant_predict')}, #{I18n.t('.messages.common.please')}, #{I18n.t('.messages.common.try_again')}"
                  end
                else
                  flash[:error] = I18n.t('.messages.matches.cant_cheat')
                end
              else
                flash[:error] = I18n.t('.messages.matches.late_prediction')
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
