module FunkyWorldCup
  class Groups < Cuba
    define do
      on get do
        @user_rank ||= UserScore.rank_for(current_user.id)
        on root do
          groups = current_user.groups
          res.write render("./views/layouts/application.html.erb") {
            render("./views/groups/index.html.erb", groups: groups)
          }
        end

        on "new" do
          res.write render("./views/layouts/application.html.erb") {
            render("./views/groups/new.html.erb", params: session.delete('fwc.group_params') || {})
          }
        end

        on ":id" do |group_id|
          on (group = Group[group_id.to_i]) do
            on root do
              # when user is kicked from group refresh session and redirect
              unless GroupsUser.find(group_id: group_id, user_id: current_user.id)
                authenticate(User[current_user.id])
                flash[:warning] = I18n.t('.messages.group.dont_belong')
                res.redirect "/dashboard"
              end

              res.write render("./views/layouts/application.html.erb") {
                render("./views/groups/show.html.erb",
                       group: group,
                       participants: group.participants,
                       prizes: group.group_prizes,
                       url: ENV['FWC_URL']
                      )
              }
            end

            on group.user_id == current_user.id do
              on "edit" do
                res.write render("./views/layouts/application.html.erb") {
                  render("./views/groups/edit.html.erb", group: group, params: session.delete('fwc.group_params_edit') || {} )
                }
              end

              on "prizes" do
                res.write render("./views/layouts/application.html.erb") {
                  render("./views/groups/prizes.html.erb", prizes: group.group_prizes, group: group)
                }
              end

              not_found!
            end

            not_found!
          end

          not_found!
        end

        not_found!
      end

      on post do
        on root do
          begin
            group = req.params['group'].strip
            group_form = FunkyWorldCup::Validators::GroupForm.hatch(group)
            raise ArgumentError.new(group_form.errors.full_messages.join(', ')) unless group_form.valid?
            raise ArgumentError.new("Name can not be repeated") unless Group.where(name: group['name']).and(user_id: current_user.id).all.empty?

            new_group = Group.create(
              name: group['name'],
              description: group['description'],
              user_id: current_user.id,
              link: FunkyWorldCupApp::generate_group_link
            )

            GroupsUser.create(group_id: new_group.id, user_id: current_user.id)
            authenticate(User[current_user.id])

            flash[:success] = "#{group['name']} #{I18n.t('.messages.groups.created')}"
            res.redirect "/groups/#{new_group.id}"
          rescue => e
            flash[:error] = e.message
            session['fwc.group_params'] = group
            res.redirect '/groups/new'
          end
        end

        not_found!
      end

      on put do
        on ":id" do |group_id|
          on (group = Group[group_id.to_i]) do
            on group.user_id == current_user.id do
              on root do
                begin
                  group_params = req.params['group'].strip
                  group_form = FunkyWorldCup::Validators::GroupForm.hatch(group_params)
                  raise ArgumentError.new(group_form.errors.full_messages.join(', ')) unless group_form.valid?
                  raise ArgumentError.new("Name can not be repeated") unless Group.where(name: group_params['name']).and(user_id: current_user.id).all.empty?

                  group.name = group_params['name']
                  group.description = group_params['description']
                  group.save

                  flash[:success] = "#{group.name} #{I18n.t('.messages.groups.updated')}"
                  res.redirect "/groups/#{group.id}"
                rescue => e
                  flash[:error] = e.message
                  session['fwc.group_params_edit'] = group
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

                  flash[:success] = I18n.t('.messages.groups.deleted')
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
