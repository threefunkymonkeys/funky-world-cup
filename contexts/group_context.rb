module FunkyWorldCup
  class GroupContext
    attr_reader :user, :group

    def initialize(ctx, params)
      @ctx = ctx
      @user = ctx.current_user
      @params = params
    end
    
    def join_group
      unless @user
        @ctx.session['fwc.join_group_code'] = @params[:code]
        @ctx.flash[:info] = I18n.t('.messages.common.sign_in_first')
        return :not_logged_in
      end

      if @group = Group.find(link: @params[:code])
        begin
          GroupsUser.create(group_id: group.id, user_id: @user.id)
          authenticate(User[@user.id])
          @ctx.flash[:success] = I18n.t('.messages.groups.joined')
          return :success
        rescue => e
          @ctx.flash[:error] = "#{I18n.t('.messages.groups.cant_join')} #{group.name}, #{I18n.t('.messages.common.please')} #{I18n.t('.messages.common.try_again')}"
          return :error
        end
      else
        return :not_found
      end
    end
  end
end
