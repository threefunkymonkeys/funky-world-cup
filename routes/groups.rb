module FunkyWorldCup
  class Groups < Cuba
    define do
      on get do
        on root do
          groups = current_user.groups
          res.write render("./views/layouts/application.html.erb") {
            render("./views/pages/groups/index.html.erb", groups: groups)
          }
        end

        on "new" do
          res.write render("./views/layouts/application.html.erb") {
            render("./views/pages/groups/new.html.erb", params: session.delete('fwc.group_params') || {})
          }
        end

        on ":id" do |group_id|
          if group = Group[group_id]
            res.write render("./views/layouts/application.html.erb") {
              render("./views/pages/groups/show.html.erb", group: group)
            }
          else
            not_found!
          end
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
              user_id: current_user.id
            )

            GroupsUser.create(group_id: new_group.id, user_id: current_user.id)

            flash[:success] = "The group '#{group['name']}' was created"
            res.redirect "/groups/#{new_group.id}"
          rescue => e
            flash[:error] = e.message
            session['fwc.group_params'] = group
            res.redirect '/groups/new'
          end
        end

        not_found!
      end

      not_found!
    end
  end
end
