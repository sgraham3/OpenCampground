# Be sure to restart your server when you modify this file.

ActiveSupport::CoreExtensions::Date::Conversions::DATE_FORMATS.merge!(
	:us	       => '%m/%d/%Y',
	:short_ordinal => lambda { |date| date.strftime("%b #{date.day.ordinalize}, %Y") }
)
