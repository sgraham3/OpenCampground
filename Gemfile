source 'https://rubygems.org'
git 'https://github.com/makandra/rails.git', :branch => '2-3-lts' do
  gem 'rails', '~>2.3.18'
  gem 'actionmailer',     :require => false
  gem 'actionpack',       :require => false
  gem 'activerecord',     :require => false
  gem 'activeresource',   :require => false
  gem 'activesupport',    :require => false
  gem 'railties',         :require => false
  gem 'railslts-version', :require => false
end

gem  'rake', '~> 10.5.0'
gem  'test-unit', '1.2.3'
gem  'mysql2'
gem  'activerecord-mysql2-adapter'
gem  'calendar_date_select', '1.16.4'
gem  'liquid', '~> 2.6.0'
gem  'acts_as_list', '0.1.2'
gem  'i18n', '0.6.9'
gem  'activemerchant', '1.33.0'
gem  'money'
gem  'builder', '3.2.2'
gem  'json'
gem  'active_utils', '2.0.2'
gem  'will_paginate', '2.3.16'
gem  'in_place_editing', '1.2.0'
gem  'faraday', '0.9.0'
gem  'faraday_middleware', '0.9.1'
gem  'multipart-post', '1.2.0'

# bundler requires these gems in all environments
gem 'nokogiri', '1.5.10'
gem 'geokit'

group :development do
  # bundler requires these gems in development
  gem 'rails-footnotes'
  gem  'thin'
end

group :test do
  # bundler requires these gems while running tests
  gem "rspec", "=1.3.2", git: 'https://github.com/makandra/rspec.git', branch: '1-3-lts'
  gem "rspec-rails", "=1.3.4", git: 'https://github.com/makandra/rspec-rails.git', branch: '1-3-lts'
  gem 'faker'
end

