module FunkyWorldCup
  class JoinGroup
    attr_reader :user, :group

    def initialize(ctx)
      @ctx = ctx
      @user = ctx.current_user
    end
    
    def execute(group)
      return :not_found if group.nil?

      begin
        GroupsUser.create(group_id: group.id, user_id: @user.id)
        @ctx.authenticate(User[@user.id])
        @ctx.flash[:success] = I18n.t('.messages.groups.joined')
        return :success
      rescue => e
        @ctx.flash[:error] = "#{I18n.t('.messages.groups.cant_join')} #{group.name}, #{I18n.t('.messages.common.please')} #{I18n.t('.messages.common.try_again')}"
        return :error
      end
    end
  end
end
