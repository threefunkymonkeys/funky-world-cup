module FunkyWorldCup
  class LeaveGroup
    attr_reader :user, :group

    def initialize(ctx)
      @ctx = ctx
      @user = ctx.current_user
    end

    def execute(group)
      return :not_found if group.nil?

      begin
        participant = GroupsUser.find(user_id: @user.id, group_id: group.id)
        return :not_found if participant.nil?
        participant.delete
        @ctx.authenticate(User[@user.id])
        @ctx.flash[:success] = "#{I18n.t('.messages.groups.user_left')} \"#{group.name}\""
        return :success
      rescue => e
        @ctx.flash[:error] = "#{I18n.t('.messages.groups.cant_leave')} \"#{group.name}\", #{I18n.t('.messages.common.please')}, #{I18n.t('.messages.common.try_again')}"
        return :error
      end
    end
  end
end
