class Discount < ActiveRecord::Base
  has_many :reservations
  acts_as_list
  validate :either_or?
  validates_presence_of :name
  validates_uniqueness_of :name
  validates_numericality_of :discount_percent,
                            :greater_than_or_equal_to => 0.00,
                            :less_than_or_equal_to => 100.00
  before_destroy :check_use
  before_save :zap_nul
  before_validation :check_amounts

  # constants for how applied
  ONCE = 1
  PER_DAY = 2
  PER_WEEK = 3
  PER_MONTH = 4
  # constants for length and delay
  DAY = 1
  WEEK = 2
  MONTH = 3

  default_scope :order => :position
  named_scope :active, :conditions => ["active = ?", true]
  named_scope :for_remote, :conditions => ["active = ? and show_on_remote = ?", true, true]

  attr_accessor :use_duration

  # after this we will use the duration
  def after_find
    logger.debug "update_duration, duration is #{duration}"
    self.use_duration = duration > 0
    logger.debug "use_duration is #{use_duration}"
  end

  def _duration_units
    units(duration_units)
  end

  def _delay_units
    units(delay_units)
  end

  def units(unit)
    case unit
    when DAY
      'day(s)'
    when WEEK
      'weeks(s)'
    when MONTH
      'month(s)'
    end
  end

  def charge(total, units = Charge::DAY, startdate = currentDate, count = 1)
    # duration persists but count if new each call
    ActiveRecord::Base.logger.debug "Discount#charge called with total = #{total}, units = #{units}, count = #{count} duration = #{duration} use_duration = #{use_duration}"
    # duration contains the number of days/weeks/months left in the discount
    return 0.0 if use_duration && duration == 0 # this discount is used up
    return amount if amount > 0.0 # this is an amount discount

    original_count = count
    discounted = 0
    cur = startdate
    logger.debug "starting discount processing"
    # see how many times we will apply the discount
    if use_duration
      while duration > 0 && count > 0
        case units
        when Charge::DAY
          # if day is discounted
          ActiveRecord::Base.logger.debug "#{cur.day} is #{send(cur.strftime('%A').downcase)}"
          discounted += 1 if send(cur.strftime("%A").downcase.to_sym)
          cur = cur.succ
        when Charge::WEEK, Charge::MONTH
          discounted += 1
        when Charge::SEASON, Charge::STORAGE
          return total * discount_percent / 100.0 if disc_appl_seasonal
        else
          return 0.0
        end
        self.duration -= 1
        count -= 1
      end
      return 0.0 if discounted == 0
    else
      discounted = count
    end

    ActiveRecord::Base.logger.debug "amount_monthly = #{amount_monthly}, discounted = #{discounted}"
    case units
    when Charge::DAY
      return total * discounted / original_count * discount_percent / 100.0 if disc_appl_daily && discount_percent > 0.0
      return amount_daily * discounted if amount_daily > 0.0
    when Charge::WEEK
      return total * discounted / original_count * discount_percent / 100.0 if disc_appl_week && discount_percent > 0.0
      return amount_weekly * discounted if amount_weekly > 0.0
    when Charge::MONTH
      return total * discounted / original_count * discount_percent / 100.0 if disc_appl_month && discount_percent > 0.0
      return amount_monthly * discounted if amount_monthly > 0.0
    end
    0.0
  end

  def self.skip_seasonal?
    # true if no discounts apply to seasonal
    all.each { |d| return false if d.disc_appl_seasonal }
    true
  end

  private

  def zap_nul
    delay ||= 0
    duration ||= 0
  rescue StandardError
  end

  def either_or?
    errors.add(:discount_percent, "specified and amount specified.  Can only have amount or percent not both") if (discount_percent != 0.0) && ((amount + amount_daily + amount_weekly + amount_monthly) != 0.0)
    errors.add(:amount, "Once provided.  Cannot have daily, weekly or monthly if once is selected") if (amount != 0.0) && ((amount_daily + amount_weekly + amount_monthly) != 0.0)
    errors.add(:discount_percent, "specified and no applicability specified.  One of the applies to items must be selected") if (discount_percent != 0.0) && !(disc_appl_daily | disc_appl_week | disc_appl_month | disc_appl_seasonal)
  end

  def check_use
    res = Reservation.find_all_by_discount_id id
    return unless res.size > 0

    lst = ''
    res.each { |r| lst << " #{r.id}," }
    errors.add "discount in use by reservation(s) #{lst}"
    false
  end

  def check_amounts
    amount ||= 0.0
    amount_daily ||= 0.0
    amount_weekly ||= 0.0
    amount_monthly ||= 0.0
    discount_percent ||= 0.0
  end
end
