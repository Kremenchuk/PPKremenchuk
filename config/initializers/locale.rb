I18n.load_path += Dir[Rails.root.join('config', 'locales', '*.{rb,yml}')]

I18n.default_locale = :uk
I18n.available_locales = %i[uk en]

# Fall back to Ukrainian for any keys missing in en.
require 'i18n/backend/fallbacks'
I18n::Backend::Simple.include(I18n::Backend::Fallbacks)
I18n.fallbacks = I18n::Locale::Fallbacks.new(uk: %i[uk], en: %i[en uk])
