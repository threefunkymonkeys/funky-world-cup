module FunkyWorldCup
  class Users < Cuba
    define do
      on put, ":id/toggle_rules" do |user_id|
        not_found! unless user_id == current_user.id || current_user.admin

        current_user.update(show_rules: !current_user.show_rules)

        no_content!
      end

      on get do
        calculate_user_rank

        on :id do |user_id|
          on current_user && (current_user.id == user_id.to_i || current_user.admin || FunkyWorldCup.finalized?) && user = User[user_id] do

            on "predictions" do
              not_found! unless root
              predictions = MatchPrediction.select(Sequel.qualify(:match_predictions, :id), :host_score, :rival_score, :prediction_score, :match_id)
                                           .join(:matches, :id => :match_id)
                                           .eager(:match)
                                           .where(user_id: user_id)
                                           .order(:start_datetime)

              res.write render("./views/layouts/application.html.erb") {
                render("./views/users/predictions.html.erb", predictions: predictions, user: User[user_id])
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
                    FunkyWorldCup::Helpers.database.transaction do
                      prediction = MatchPrediction.create(
                                    user_id:     current_user.id,
                                    match_id:    params['match_id'].to_i,
                                    host_score:  params['host_score'].to_i,
                                    rival_score: params['rival_score'].to_i
                                  )
                      if match.allow_penalties? && (params['host_score'].to_i == params['rival_score'].to_i)
                        MatchPenaltiesPrediction.create(
                          user_id:     current_user.id,
                          match_id:    params['match_id'].to_i,
                          host_score:  params['host_penalties_score'].to_i,
                          rival_score: params['rival_penalties_score'].to_i,
                          match_prediction_id: prediction.id
                        )
                      end
                    end
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

            on 'contact' do
              attrs = req.params['address'].strip
              FunkyWorldCup::ContactCreate.new(self).execute(attrs)
              res.redirect "/"
            end

            not_found!
          end

          not_found!
        end

        not_found!
      end

      not_found!
    end
  end
end
