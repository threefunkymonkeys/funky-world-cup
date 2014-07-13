module FunkyWorldCup
  class ContactCreate
    def initialize(context)
      @ctx = context
      @user = context.current_user
    end

    def execute(attributes)
      begin
        contact_form = FunkyWorldCup::Validators::ContactForm.hatch(attributes)

        unless contact_form.valid?
          raise ArgumentError.new(contact_form.errors.full_messages.join(', '))
        end

        contact = UserContact.create(
          email: attributes['email'],
          address: attributes['address'],
          post_code: attributes['post_code'],
          city: attributes['city'],
          state: attributes['state'],
          country: attributes['country'],
          comment: attributes['comment'],
          user_id: @user.id
        )

        @ctx.flash[:success] = "#{I18n.t('.dashboard.form.saved')}"
        contact
      rescue => e
        @ctx.flash[:error] = e.message
        @ctx.session['fwc.contact_form'] = attributes
        false
      end
    end
  end
end

