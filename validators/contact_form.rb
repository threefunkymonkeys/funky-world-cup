module FunkyWorldCup::Validators
  class ContactForm
    include Hatch

    certify('email', I18n.t(".dashboard.form.email_not_empty")) do |email|
      !email.nil? && !email.empty?
    end

    certify('address', I18n.t(".dashboard.form.address_not_empty")) do |address|
      !address.nil? && !address.empty?
    end

    certify('post_code', I18n.t(".dashboard.form.post_code_not_empty")) do |post_code|
      !post_code.nil? && !post_code.empty?
    end

    certify('city', I18n.t(".dashboard.form.city_not_empty")) do |city|
      !city.nil? && !city.empty?
    end

    certify('state', I18n.t(".dashboard.form.state_not_empty")) do |state|
      !state.nil? && !state.empty?
    end

    certify('country', I18n.t(".dashboard.form.country_not_empty")) do |country|
      !country.nil? && !country.empty?
    end
  end
end

