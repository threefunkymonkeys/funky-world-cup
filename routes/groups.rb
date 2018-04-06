module FunkyWorldCup
  class Groups < Cuba
    settings[:render][:layout] = "layouts/application.html"

    define do
      on get, "join/:code" do |code|
        on group = Group.find(link: code) do
          unless current_user
            session['fwc.join_group_code'] = code
          end
          res.write render("./views/layouts/join.html.erb", group: group) {
            render("./views/groups/join.html.erb", group: group)
          }
        end

        not_found!
      end

      on current_user do
        on get do
          on root do
            groups = current_user.groups

            res.write view("groups/index.html", groups: groups, url: ENV["FWC_URL"])
          end

          on "new" do
            res.write view("groups/new.html", params: session.delete('fwc.group_params') || {})
          end

          on ":id" do |group_id|
            group = Group[group_id.to_i]
            not_found! unless group

            on root do
              # when user is kicked from group refresh session and redirect
              unless GroupsUser.find(group_id: group_id, user_id: current_user.id)
                authenticate(User[current_user.id])
                flash[:warning] = I18n.t('.messages.group.dont_belong')
                res.redirect "/dashboard"
              end

              res.write view(
                "groups/show.html",
                group:        group,
                participants: group.participants_by_rank,
                prizes:       group.group_prizes,
                url:          ENV['FWC_URL'],
              )
            end

            on group.user_id == current_user.id do
              on "edit" do
                res.write view(
                  "groups/edit.html",
                  group:  group,
                  params: session.delete('fwc.group_params_edit') || {},
                )
              end

              on "prizes" do
                res.write view(
                  "groups/prizes.html",
                  prizes: group.group_prizes,
                  group:  group,
                )
              end

              not_found!
            end

            not_found!
          end

          not_found!
        end

        on post do
          on root do
            attrs = req.params['group'].strip
            if group = FunkyWorldCup::GroupCreate.new(self).execute(attrs)
              res.redirect "/groups/#{group.id}"
            else
              res.redirect '/groups/new'
            end
          end

          not_found!
        end

        on put do
          on "join/:code" do |code|
            group = Group.find(link: code)
            case FunkyWorldCup::JoinGroup.new(self).execute(group)
            when :success
              res.redirect "/groups/#{group.id}"
            when :error
              res.redirect "/dashboard"
            when :not_found
              not_found!
            end
          end

          on ":id" do |group_id|
            on (group = Group[group_id.to_i]) do
              on group.user_id == current_user.id do
                on root do
                  attrs = req.params['group'].strip
                  if FunkyWorldCup::GroupUpdate.new(self, group).execute(attrs)
                    res.redirect "/groups/#{group.id}"
                  else
                    res.redirect "/groups/#{group.id}/edit"
                  end
                end

                on "prizes" do
                  old = group.group_prizes

                  new = Array.new
                  begin
                    FunkyWorldCup::Helpers.database.transaction(rollback: :reraise) do
                      req.params['prizes'].each_with_index do |prize, index|
                        GroupPrize.create(name: prize, group_id: group.id, order: index +1)
                      end

                      old.each do |prize|
                        prize.delete
                      end
                    end
                    flash[:success] = I18n.t('.messages.prizes.list_updated')
                    res.redirect "/groups/#{group.id}"
                  rescue Sequel::Rollback
                    flash[:error] = "#{I18n.t('.messages.prizes.cant_save_list')}, #{I18n.t('.messages.common.please')} #{I18n.t('.messages.common.try_again')}"
                    session['fwc.pizes'] = req.params['prizes']
                    res.redirect "/groups/#{group.id}/prizes"
                  end
                end

                on "reset_link" do
                  begin
                    group.link = FunkyWorldCupApp::generate_group_link(group.id)
                    group.save
                    flash[:success] = I18n.t('.messages.groups.link_updated')
                  rescue => e
                    puts e.inspect
                    flash[:error] = "#{I18n.t('.messages.groups.cant_update_link')}, #{I18n.t('.messages.common.please')} #{I18n.t('.messages.common.try_again')}"
                  end
                  res.redirect "/groups/#{group.id}"
                end

                not_found!
              end

              not_found!
            end

            not_found!
          end

          not_found!
        end

        on delete do
          on ":id" do |group_id|
            on (group = Group[group_id.to_i]) do
              on group.user_id == current_user.id do
                on root do
                  begin
                    #cascade is enabled
                    group.delete
                    authenticate(User[current_user.id])

                    flash[:success] = I18n.t('.messages.groups.updated')
                    res.redirect "/groups"
                  rescue => e
                    flash[:error] = "#{I18n.t('.messages.groups.cant_delete')}, #{I18n.t('.messages.common.please')} #{I18n.t('.messages.common.try_again')}"
                    res.redirect "/groups/#{group.id}"
                  end
                end

                on "kick/:user_id" do |user_id|
                  not_found! unless root

                  begin
                    GroupsUser.find(user_id: user_id, group_id: group.id).delete

                    flash[:success] = I18n.t('.messages.groups.participant_kicked')
                  rescue => e
                    flash[:error] = "#{I18n.t('.messages.groups.cant_kick')}, #{I18n.t('.messages.common.please')}, #{I18n.t('.messages.common.try_again')}"
                  end
                  res.redirect "/groups/#{group.id}"
                end

                not_found!
              end

              on 'leave' do
                case FunkyWorldCup::LeaveGroup.new(self).execute(group)
                when :success
                  res.redirect "/"
                when :error
                  res.redirect "/groups/#{group.id}"
                when :not_found
                  not_found!
                end
              end

              not_found!
            end

            not_found!
          end

          not_found!
        end

        not_found!
      end #current_user

      not_found!
    end #define
  end
end
