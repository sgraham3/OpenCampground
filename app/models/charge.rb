# a class for storing charges
class Charge < ActiveRecord::Base
  include CalculationHelper
  include MyLib
  belongs_to :reservation
  belongs_to :season
  # ordered_by 'start_date ASC'
  DAY = 0
  WEEK = 1
  MONTH = 2
  SEASON = 3
  STORAGE = 4

  # named_scope :stay, lambda { |id| :conditions => ['reservation_id = ?', id] }
  # named_scope :stay, lambda { |id| :conditions => ['reservation_id = ?', id]}, :order => 'start_date ASC'
  def self.stay(id)
    all(:conditions => ["reservation_id = ?", id], :order => 'start_date ASC')
  end

  def +(other)
    # ActiveRecord::Base.logger.debug "self  #{self.start_date} to #{self.end_date}"
    # ActiveRecord::Base.logger.debug "other #{other.start_date} to #{other.end_date}"
    raise 'different_units' if self.charge_units != other.charge_units
    raise 'different_rate' if self.rate != other.rate
    raise 'different_reservation' if self.reservation_id != other.reservation_id
    raise 'different_season' if self.season_id != other.season_id
    if self.start_date == other.end_date
      start_date = other.start_date
      end_date = self.end_date
    elsif self.end_date == other.start_date
      start_date = self.start_date
      end_date = other.end_date
    else
      # ActiveRecord::Base.logger.debug 'raise not_sequential'
      # ActiveRecord::Base.logger.debug "	self  #{self.start_date} to #{self.end_date}"
      # ActiveRecord::Base.logger.debug "	other #{other.start_date} to #{other.end_date}"
      raise 'not_sequential'
    end
    period = self.period + other.period
    amount = self.amount + other.amount
    discount = self.discount + other.discount
    return self.class.new(:reservation_id => self.reservation_id,
			  :season_id => self.season_id,
			  :rate => self.rate,
			  :charge_units => self.charge_units,
			  :period => period,
			  :amount => amount,
			  :discount => discount,
			  :start_date => start_date,
			  :end_date => end_date)
  end

  def combine(other)
    raise 'different_units' if self.charge_units != other.charge_units
    raise 'different_rate' if self.rate != other.rate
    raise 'different_season' if self.season_id != other.season_id
    raise 'different_reservation' if self.reservation_id != other.reservation_id
    if self.start_date == other.end_date
      self.start_date = other.start_date
    elsif self.end_date == other.start_date
      self.end_date = other.end_date
    else
      # ActiveRecord::Base.logger.debug 'raise not_sequential'
      # ActiveRecord::Base.logger.debug "	self  #{self.start_date} to #{self.end_date}"
      # ActiveRecord::Base.logger.debug "	other #{other.start_date} to #{other.end_date}"
      raise 'not_sequential'
    end
    self.period = self.period + other.period
    if (self.start_date.day == self.end_date.day) && (self.charge_units == Charge::MONTH)
      ActiveRecord::Base.logger.debug "even month #{self.start_date} to #{self.end_date}"
      self.period = (self.period + 0.4).to_i
      self.amount = self.rate * self.period
    else
      self.amount = self.amount + other.amount
    end
    self.discount = self.discount + other.discount
  end

end
