module FunkyWorldCup
  class GroupCreate
    def initialize(context)
      @ctx = context
      @user = context.current_user
    end

    def execute(attributes)
      begin
        group_form = FunkyWorldCup::Validators::GroupForm.hatch(attributes)

        unless group_form.valid?
          raise ArgumentError.new(group_form.errors.full_messages.join(', '))
        end

        if Group.where(:user_id => @user.id, :name => attributes['name']).any?
          raise ArgumentError.new("Name can not be repeated")
        end

        group = Group.create(
          name: attributes['name'],
          description: attributes['description'],
          user_id: @user.id,
          link: FunkyWorldCupApp::generate_group_link
        )

        @user.add_group(group)
        @ctx.authenticate(@user)

        @ctx.flash[:success] = "#{group.name} #{I18n.t('.messages.groups.created')}"
        group
      rescue => e
        @ctx.flash[:error] = e.message
        @ctx.session['fwc.group_params'] = attributes
        false
      end
    end
  end
end
