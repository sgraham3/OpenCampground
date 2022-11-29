class Season < ActiveRecord::Base
  include MyLib

  has_many :rates, :dependent => :destroy
  has_many :prices, :through => :rates
  has_many :charges
  validate :valid_dates?
  validates_presence_of :name, :startdate, :enddate
  validates_uniqueness_of :name
  named_scope :active, :conditions => ["active = ?", true]

  #######################################################
  # find the season that best applies to this date
  # we look for a season that starts before the date
  # starts and ends after the date.
  # Only returns the shortest season enclosing the date
  #######################################################
  def self.find_by_date(res_start=currentDate)
    # ActiveRecord::Base.logger.debug "find_by_date for #{res_start}"
    seasons = all(:conditions=>["active = ? and startdate <= ? and enddate >= ?", true, res_start, res_start],
		  :order => 'startdate DESC')
    return shortest(seasons)
  end

  def self.find_monthly_by_date(res_start=currentDate)
    # ActiveRecord::Base.logger.debug "find_monthly_by_date for #{res_start}"
    seasons = all(:conditions=>["active = ? and applies_to_monthly = ? and startdate <= ? and enddate >= ?", true, true, res_start, res_start],
		  :order => 'startdate DESC')
    # ActiveRecord::Base.logger.debug "find_monthly_by_date for #{res_start}, season is #{shortest(seasons).name}"
    return shortest(seasons)
  end

  def self.find_weekly_by_date(res_start=currentDate)
    # ActiveRecord::Base.logger.debug "find_weekly_by_date for #{res_start}"
    seasons = all(:conditions=>["active = ? and applies_to_weekly = ? and startdate <= ? and enddate >= ?", true, true, res_start, res_start],
		  :order => 'startdate DESC')
    return shortest(seasons)
  end

  def self.one_storage_rate(price_id = 1)
    return true if count == 1
    rate = Rate.find_current_rate(1, price_id).monthly_storage
    active.each {|s| return false if Rate.find_current_rate(s.id, price_id).monthly_storage != rate}
    return true
  end
    

private

  #######################################################
  # make sure end date is greater than start date
  #######################################################
  def valid_dates?
    if enddate && startdate && enddate <= startdate
      errors.add(:enddate,  "is before startdate")
    end
  end

  def self.shortest(seasons)
    short = 99999999
    s = seasons[0]
    seasons.each do |season|
      length = season.enddate - season.startdate
      # ActiveRecord::Base.logger.debug "length = #{length}, short is #{short}, season is #{s.id}"
      if length < short
	s = season
	short = length
	# ActiveRecord::Base.logger.debug "shortest season is #{s.id}"
      end
    end
    return s
  end

end
