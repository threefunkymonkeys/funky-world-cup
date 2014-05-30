module FunkyWorldCup
  class GroupUpdate
    def initialize(context, group)
      @ctx = context
      @user = context.current_user
      @group = group
    end

    def execute(attributes)
      begin
        group_form = FunkyWorldCup::Validators::GroupForm.hatch(attributes)

        unless group_form.valid?
          raise ArgumentError.new(group_form.errors.full_messages.join(', '))
        end

        if Group.where(name: attributes['name'], user_id: @user.id).any?
          raise ArgumentError.new("Name can not be repeated")
        end

        @group.update(name: attributes['name'],
                      description: attributes['description'])

        @ctx.flash[:success] = "#{@group.name} #{I18n.t('.messages.groups.updated')}"
        true
      rescue => e
        @ctx.flash[:error] = e.message
        @ctx.session['fwc.group_params_edit'] = @group
        false
      end

    end
  end
end
