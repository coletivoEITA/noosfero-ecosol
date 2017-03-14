##
# Support for I18n.default_locale
#
require 'i18n/backend/fallbacks'
I18n.backend.class.send :include, I18n::Backend::Fallbacks
I18n.config.missing_interpolation_argument_handler = -> *args {}

Rails.application.config.middleware.use I18n::JS::Middleware

