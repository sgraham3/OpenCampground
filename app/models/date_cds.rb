require 'date'
class DateCds
#
#  date:
#    formats:
#      default: "%m-%d-%Y"
#      long: "%B %d, %Y"
#      short: "%b %d"
#      month: "%B"
#    order: [ :month, :day, :year ]
#    month_names: [~, January, February, March, April, May, June, July, August, September, October, November, December]
#    abbr_month_names: [~, Jan, Feb, Mar, Apr, May, Jun, Jul, Aug, Sep, Oct, Nov, Dec]
#    day_names: [ Sunday, Monday, Tuesday, Wednesday, Thursday, Friday, Saturday]
#    abbr_day_names: [ Sun, Mon, Tue, Wed, Thu, Fri, Sat]
#
  def self.parse_cds(str)
    # specificly to parse the string coming from calendar_date_select
    english_months = %w(~ Jan Feb Mar Apr May Jun Jul Aug Sep Oct Nov Dec)
    # get the month names used in this locale
    month_names = I18n.t('date.month_names')
    ActiveRecord::Base.logger.debug "month_names = #{month_names.inspect}"

    # split the string into three elements which contain the day, month, year
    p_str = str.split(' ')
    ActiveRecord::Base.logger.debug "p_str = #{p_str.inspect}"
    # get the index of the month
    m_index = month_names.find_index(p_str[1])
    ActiveRecord::Base.logger.debug "m_index = #{m_index} for #{p_str[1]}"
    # change the month to the english version
    p_str[1] = english_months[m_index]
    ActiveRecord::Base.logger.debug "month is now #{p_str[1]}"
    # parse the values to return the value wanted
    Date.parse "#{p_str[2]}-#{p_str[1]}-#{p_str[0]}"
  end
end
