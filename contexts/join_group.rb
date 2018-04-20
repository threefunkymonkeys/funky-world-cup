module FunkyWorldCup
  class JoinGroup
    attr_reader :user, :group

    def initialize(ctx)
      @ctx  = ctx
      @user = ctx.current_user
    end

    def execute(group)
      return :not_found if group.nil?

      if GroupsUser[group_id: group.id, user_id: @user.id]
        @ctx.flash[:info] = I18n.t('.messages.groups.already_in')

        return :membership_exists
      end

      begin
        GroupsUser.create(group_id: group.id, user_id: @user.id)

        @ctx.authenticate(User[@user.id])
        @ctx.flash[:success] = I18n.t('.messages.groups.joined')

        return :success
      rescue => e
        @ctx.flash[:error] = [
          I18n.t('.messages.groups.cant_join'),
          "#{group.name},",
          I18n.t('.messages.common.please'),
          I18n.t('.messages.common.try_again'),
        ].join(" ")

        return :error
      end
    end
  end
end
