class Rate < ActiveRecord::Base
  belongs_to :season
  belongs_to :price

 def not_storage
    return true if monthly_storage < 0.01
    false
  end

  def not_seasonal
    return true if seasonal_rate < 0.01
    false
  end

  def no_rate?(days=0)
    option = Option.first
    if option.variable_rates
      return true if days < 7 && monday == 0.0
      return true if monday == 0.0 && weekly_rate == 0.0 && monthly_rate == 0.0
    else
      return true if days < 7 && daily_rate == 0.0
      return true if daily_rate == 0.0 && weekly_rate == 0.0 && monthly_rate == 0.0
    end
    false
  end

  def before_create
    ActiveRecord::Base.logger.debug "daily rate is #{self.daily_rate}"
    self.daily_rate = 0.0 unless self.daily_rate
    ActiveRecord::Base.logger.debug "weekly rate is #{self.weekly_rate}"
    self.weekly_rate = 0.0 unless self.weekly_rate
    ActiveRecord::Base.logger.debug "monthly rate is #{self.monthly_rate}"
    self.monthly_rate = 0.0 unless self.monthly_rate
    ActiveRecord::Base.logger.debug "seasonal rate is #{self.seasonal_rate}"
    self.seasonal_rate = 0.0 unless self.seasonal_rate
    ActiveRecord::Base.logger.debug "monthly storage rate is #{self.monthly_storage}"
    self.monthly_storage = 0.0 unless self.monthly_storage
    self.sunday = 0.0 unless self.sunday
    self.monday = 0.0 unless self.monday
    self.tuesday = 0.0 unless self.tuesday
    self.wednesday = 0.0 unless self.wednesday
    self.thursday = 0.0 unless self.thursday
    self.friday = 0.0 unless self.friday
    self.saturday = 0.0 unless self.saturday
  end

  #######################################################
  # find the rates that apply given the season we are
  # using.  Return an array of rates
  #######################################################
  def self.find_current  season_id
    rates = all(:conditions => "season_id = #{season_id}",
		 :order => "price_id asc")
    return rates
  end

  #######################################################
  # find a rate given the season we are using and a
  # price_id.  Return a single rate
  #######################################################
  def self.find_current_rate  season_id, price_id
    rate = first(:conditions => ["season_id = ? and price_id = ?", season_id, price_id])
    return rate
  end

  #######################################################
  # given a rate object give the rate corresponding to
  # the input date
  #######################################################
  def rate_for_day (date, variable_rates = false)
    if variable_rates
      day = Date::DAYNAMES[date.wday]
      lcday = day.downcase
      rate = send(lcday)
      # ActiveRecord::Base.logger.info "variable rates, date is #{date}, day is #{day}, lcday is #{lcday}, rate is #{rate}"
    else
      rate = daily_rate
      # ActiveRecord::Base.logger.info "fixed rates, date is #{date}, rate is #{rate}"
    end
    # return rate
  end
end
