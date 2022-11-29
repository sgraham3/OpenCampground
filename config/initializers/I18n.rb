# -*- coding: UTF-8 -*-
# Be sure to restart your server when you modify this file.

LOCALES_DIRECTORY = Rails.root.to_s + '/config/locales/'

LANGUAGES = {
  'Deutsch' => 'de',
  'Dutch' => 'nl',
  'English(AU)' => 'en_AU',
  'English(US)' => 'en',
  'English(CA)' => 'en_CA',
  'English(GB)' => 'en_GB',
  'English(NZ)' => 'en_NZ',
  'English(ZA)' => 'en_ZA',
  "Français(CA)" => 'fr_CA',
  'Italiano' => 'it',
  'Português(BR)' => 'pt_BR',
  'Svenska' => 'sv'
}

I18n.enforce_available_locales = true
I18n::Backend::Simple.include(I18n::Backend::Fallbacks)
begin
  opt = Option.first
  # I18n.fallbacks = true
  # I18n.fallbacks = [:en_CA, :en_AU, :en_NZ, :en_GB, :en_ZA, :fr_CA, :it, :pt_BR, :de, :nl, :sv]
  I18n.default_locale = :en
  I18n.locale = opt.locale
rescue
  I18n.default_locale = :en
  I18n.locale = :en
end

