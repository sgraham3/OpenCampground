class ExtraCharge < ActiveRecord::Base
  belongs_to :reservation
  belongs_to :extra

  include CalculationHelper

  def before_save
    ActiveRecord::Base.logger.debug "ExtraCharge::before_save - measured is #{extra.extra_type == Extra::MEASURED}"
    if (extra.extra_type == Extra::MEASURED) 
      # starting with a string like 1.23400 we want to arrive at 3
      # which is the precision we will print it at
      # 
      # first split any following zeros off of it
      before,b,after = measured_rate.to_s.rpartition /[1-9]/
      before << b
      # then seperate the fraction from the whole number
      whole,frac = before.split('.')
      # get the size of the fraction
      siz=0
      siz = frac.size if frac
      # set precision to the size of the fraction no less than 2
      prec = (siz > 2 ? siz : 2)
      ActiveRecord::Base.logger.debug "siz is #{siz}, prec is #{prec}"
      write_attribute(:precision, prec)
    end
  rescue => err
    ActiveRecord::Base.logger.info "ExtraCharges::before_save error is #{err}"
    write_attribute(:precision, 2)
  end

  ###################################################
  # Class methods
  ###################################################

  def self.exists?( e_id, r_id)
    ###################################################
    # return true if a record with this combo of
    # extra_id and reservation_id exists.
    ##################################################
    cnt = all(:conditions => ["EXTRA_ID = ? and RESERVATION_ID = ?",
                              e_id, r_id]).size
    if cnt > 0
      return true
    else
      return false
    end
  end

  def self.count( e_id, r_id)
    ###################################################
    # return count for a record with this combo of
    # extra_id and reservation_id.  This should not cost
    # much because it is expected to be used just after
    # exists so the record should be cached.
    ##################################################
    return(all(:conditions => ["EXTRA_ID = ? and RESERVATION_ID = ?",
                                e_id, r_id]).size)
  rescue
    # record was not found so we tossed an exception
    return 0
  end

  def self.number(e_id, r_id)
    ###################################################
    # return number of occurances for this charge
    ###################################################
    return(first(:conditions => ["EXTRA_ID = ? and RESERVATION_ID = ?",
                                e_id, r_id]).number)
  end 

  def self.charges_by_res (r_id)
    total = 0.0
    if extra_charge = all(:conditions => ["RESERVATION_ID = ?", r_id])
      extra_charge.each do |ec|
	total += ec.daily_charges + ec.weekly_charges + ec.monthly_charges + ec.charge
      end
    end
    total
  end
  ###################################################
  # Instance methods
  ###################################################
  
  def save_charges( number = 0)
    ###################################################
    # calculate the charges associated with
    # this instance and save in self
    # input is count which will be saved
    ###################################################
    #.integer "extra_id"
    #.integer "reservation_id"
    #.integer "number",                                         :default => 0
    #.integer "days",                                           :default => 0
    #.integer "weeks",                                          :default => 0
    #.integer "months",                                         :default => 0
    #.decimal "daily_charges",   :precision => 12, :scale => 2, :default => 0.0
    #.decimal "weekly_charges",  :precision => 12, :scale => 2, :default => 0.0
    #.decimal "monthly_charges", :precision => 12, :scale => 2, :default => 0.0
    #.decimal "initial",         :precision => 12, :scale => 2, :default => 0.0
    #.decimal "final",           :precision => 12, :scale => 2, :default => 0.0
    #.decimal "measured_charge", :precision => 12, :scale => 2, :default => 0.0
    #.date    "updated_on"
    #.decimal "charge",          :precision => 12, :scale => 2, :default => 0.0
    #.decimal "measured_rate",   :precision => 12, :scale => 6, :default => 0.0
    #.date    "created_on"
    #.integer "precision",                                      :default => 2
    #
    # get days, weeks, months using helper function
    # ActiveRecord::Base.logger.debug "ExtraCharge::save_charges extra_charge is #{self.inspect}"
    self.days, self.weeks, self.months =
      days_weeks_months(self.reservation.startdate,
			self.reservation.enddate,
			self.extra.weekly.to_f > 0.0,
			self.extra.monthly.to_f > 0.0)
    self.daily_charges = 0.0 unless self.days > 0
    self.weekly_charges = 0.0 unless self.weeks > 0
    self.monthly_charges = 0.0 unless self.months > 0
    self.number = number.to_i
    if self.extra_id.to_i != 0 
      case self.extra.extra_type 
      when Extra::OCCASIONAL
	self.charge = self.extra.charge * self.number
      when Extra::DEPOSIT
	self.charge = self.extra.charge
      when Extra::MEASURED
	self.charge = (self.measured_rate * (self.final.to_f - self.initial.to_f)).round(2)
      when Extra::STANDARD
	self.monthly_charges = self.months * self.extra.monthly if self.months && self.months > 0
	self.weekly_charges = self.weeks * self.extra.weekly if self.weeks && self.weeks > 0
	self.daily_charges = self.days * self.extra.daily if self.days && self.days > 0
      when Extra::COUNTED
	self.monthly_charges = self.months * self.extra.monthly * self.number if self.months && self.months > 0
	self.weekly_charges = self.weeks * self.extra.weekly * self.number if self.weeks && self.weeks > 0
	self.daily_charges = self.days * self.extra.daily * self.number if self.days && self.days > 0
      end
      self.save
    else
      ActiveRecord::Base.logger.debug "extra_id did not exist"
    end
  end

end
