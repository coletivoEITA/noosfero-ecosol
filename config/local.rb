I18n.available_locales = Noosfero.available_locales
Noosfero.default_locale = 'pt_BR'
FastGettext.locale = Noosfero.default_locale
FastGettext.default_locale = Noosfero.default_locale
I18n.locale = Noosfero.default_locale
I18n.default_locale = Noosfero.default_locale

if Rails.env.development?
  ActionMailer::Base.delivery_method = :file
end

