class Reservation < ActiveRecord::Base
  require 'my_lib'
  require 'time'
  include MyLib

  attr_reader :early_date
  attr_reader :late_date
  attr_accessor :is_remote
  validate   :valid_camper?
  validate   :valid_dates?
  validate   :no_conflict?
  validate   :manditory?
  validates_numericality_of :override_total, :allow_blank => false, :allow_nil => false, :only_integer => false
  # following set by before save
  # validates_numericality_of :adults, :only_integer => true, :allow_blank => true, :allow_nil => true
  # validates_numericality_of :pets, :only_integer => true, :allow_blank => true, :allow_nil => true
  # validates_numericality_of :slides, :only_integer => true, :allow_blank => true, :allow_nil => true
  # validates_numericality_of :rig_age, :only_integer => true
  # validates_numericality_of :kids, :only_integer => true, :allow_blank => true, :allow_nil => true
  # validates_numericality_of :length, :only_integer => true, :allow_blank => true, :allow_nil => true
  validates_presence_of :startdate, :enddate
  belongs_to :rigtype
  belongs_to :space
  belongs_to :discount
  belongs_to :recommender
  belongs_to :group
  belongs_to :camper
  has_many :extra_charges, :dependent => :delete_all
  has_many :extras, :through => :extra_charges
  has_many :charges, :dependent => :delete_all
  has_many :taxes, :dependent => :delete_all
  has_many :payments, :dependent => :delete_all
  has_many :card_transactions, :dependent => :delete_all
  has_many :paypal_transactions, :dependent => :delete_all
  has_many :variable_charges, :dependent => :delete_all

  named_scope :byres, :order => 'unconfirmed_remote, id asc'
  named_scope :bystart, :include => 'space', :order => 'unconfirmed_remote desc, startdate, enddate, group_id, spaces.position asc'
  named_scope :byend, :include => 'space', :order => 'unconfirmed_remote desc, enddate, startdate, group_id, spaces.position asc'
  named_scope :byspace, :include => ['camper', 'space'], :order => 'unconfirmed_remote desc, spaces.position, startdate, group_id, campers.last_name asc'
  named_scope :byname, :include => ['camper', 'space'], :order => 'unconfirmed_remote desc, campers.last_name, startdate, group_id, spaces.position asc'

  def purge
    arch = Archive.find_by_reservation_id id
    begin
      Archive.destroy arch.id
    rescue => err
    end
    self.destroy
  end

  def editable?
    # ActiveResource::Base.logger.debug 'editable?'
    option = Option.first
    if archived
      if option.edit_archives
        if option.use_login?
	  if User.find(User.current).admin
	    # ActiveResource::Base.logger.debug 'editable 2: admin'
	    true
	  elsif option.all_edit_archives
	    # ActiveResource::Base.logger.debug 'editable 3: user permitted'
	    true
	  else
	    # ActiveResource::Base.logger.debug 'not editable 4: no admin permissions'
	    false
	  end
	else
	  # ActiveResource::Base.logger.debug 'editable 5: login not used'
	  true
	end
      else
	# ActiveResource::Base.logger.debug 'not editable 6: archives not editable'
        false
      end
    else
      # ActiveResource::Base.logger.debug 'editable 7: not archived'
      # not archived so always editable
      true
    end
  rescue => err
    # ActiveResource::Base.logger.debug 'not editable 8 ' + err.to_s
    false
  end

  def before_save
    self.adults ||= 1
    self.pets ||= 0
    self.slides ||= 0
    self.rig_age ||= 0
    self.kids ||= 0
    self.length ||= 0
    self.onetime_discount ||= 0.0
    begin
      d = Discount.find self.discount_id
    rescue
      self.discount_id = Discount.first.id
    end
    begin
      r=Rigtype.find self.rigtype_id
    rescue
      self.rigtype_id = Rigtype.first.id
    end
  end

  def before_update
    if archived
      # archived and we are changing it
      # so we need to update changed records.
    end
  end

  def conflicts?
    conflicts = Reservation.all(:conditions => ["id != ? AND space_id = ? AND startdate < ? AND enddate > ? AND archived = ?", id, space_id, enddate, startdate, false])
    if conflicts.empty?
      return false
    else
      return conflicts
    end
  end

  def deposit_amount
    option = Option.first
    total = self.total + self.tax_amount
    dep = Hash.new
    if self.unconfirmed_remote?
      case option.deposit_type
      when Remote::Percentage
	# ActiveRecord::Base.logger.error 'Percentage'
	dep['item_name'] = ' Deposit'
	dep['amount'] = (total * option.deposit)/100.0
	dep['custom'] = "#{option.deposit}% Deposit"
	dep['tax'] = 0.0
      when Remote::Fixed_amount
	# ActiveRecord::Base.logger.error 'Fixed'
	if option.deposit > total # deposit cannot be more than the total
	  dep['item_name'] = ''
	  dep['amount'] = self.total
	  dep['custom'] = 'Full amount'
	  dep['tax'] = self.tax_amount
	else
	  dep['item_name'] = ' Deposit'
	  dep['amount'] = option.deposit
	  dep['custom'] = "$#{option.deposit} Deposit"
	  dep['tax'] = 0.0
	end
      when Remote::Days
	# ActiveRecord::Base.logger.error 'Days'
	days = option.deposit.to_i
	if (self.enddate - self.startdate).to_i > days
	  dep['item_name'] = ' Deposit'
	  dep['amount'] = Charges.days(self.startdate, self.startdate + days, self.space_id)
	  dep['custom'] = "#{days} days Deposit"
	  dep['tax'] = 0.0
	  if dep['amount'] > self.total  # possible with discounts
	    dep['item_name'] = ''
	    dep['amount'] = self.total
	    dep['custom'] = 'Full amount'
	    dep['tax'] = self.tax_amount
	  end
	else
	  dep['item_name'] = ''
	  dep['amount'] = self.total
	  dep['custom'] = 'Full amount'
	  dep['tax'] = self.tax_amount
	end
      when Remote::Full_charge
	# ActiveRecord::Base.logger.error 'Full'
	dep['item_name'] = ''
	dep['amount'] = self.total
	dep['custom'] = 'Full amount'
	dep['tax'] = self.tax_amount
      else
	ActiveRecord::Base.logger.error 'Error: Undefined deposit type'
      end
    else
      ActiveRecord::Base.logger.info 'in office paypal payment'
      # must be in office payment
      trans = PaypalTransaction.find_by_reservation_id self.id
      dep['item_name'] = ''
      if trans.amount == self.due
	ActiveRecord::Base.logger.info "amount = #{trans.amount}, due = #{self.due} Full payment"
	dep['amount'] = self.total
	dep['custom'] = 'Full amount'
	dep['tax'] = self.tax_amount
      else
	ActiveRecord::Base.logger.info "amount = #{trans.amount}, due = #{self.due} Partial payment"
	dep['amount'] = trans.amount
	dep['custom'] = 'Partial payment'
	dep['tax'] = 0.0
      end
    end
    return dep
  # rescue => err
    # ActiveRecord::Base.logger.error 'Error: ' + err.to_s
    # return false
  end

  def self.conflict(res)
    conflicts = all(:conditions => ["id != ? AND space_id = ? AND startdate < ? AND enddate > ? AND archived = ? AND confirm = ?",
	                                                res.id, res.space_id, res.enddate, res.startdate, false, true])
    if conflicts.empty?
      return false
    else
      return conflicts
    end
  end

  def self.exists?(id)
    res = find(id)
    return true
  rescue RecordNotFound
    return false
  end

  def add_log(msg = "")
    option = Option.first
  # ActiveRecord::Base.logger.debug "in add_log method"
    self.log = "" unless self.log
    begin
      time = Time.zone.now
    rescue
      time = Time.now
    end
    if option.use_login? && User.current
      self.log += msg + " by: #{User.find(User.current).name} at: #{I18n.l(time)}<br/>"
    else
      self.log += msg + " at: #{I18n.l(time)}<br/>"
    end
    self.save
  end

  # the regular expression handling here is poor 
  # and should be improved
  def co_time
    exp = /^checkout .* at: /
    exp1 = /^group checkout .* at: /
    if log && !log.empty?
      log_array = log.split('<br/>')
      log_array.reverse_each do |l|
        if l =~ /^checkout/
          return Time.parse l.sub exp,''
        elsif l =~ /^group checkout/
          return Time.parse l.sub exp1,''
        end
      end
    end
    return false
  end

  def ci_time
    exp = /^checkin .* at: /
    exp1 = /^group checkin .* at: /
    if log && !log.empty?
      log_array = log.split('<br/>')
      log_array.reverse_each do |l|
        if l =~ /^checkin/
          return Time.parse l.sub exp,''
        elsif l =~ /^group checkin/
          return Time.parse l.sub exp1,''
        end
      end
    end
    return false
  end

  def all_log_entries(ent)
    entries = []
    if log && !log.empty?
      arr = log.split('<br/>').reverse
      pattern = Regexp.new("#{ent}")
      arr.each do |l|
        entries << l if pattern.match(l)
      end
    end
  end

  def last_log_entry(ent=nil)
    if log && !log.empty?
      arr = log.split('<br/>').reverse
      if ent
        pattern = Regexp.new("#{ent}")
        arr.each {|l| return l if pattern.match(l)}
      else
        return arr[0]
      end
    end
    return nil
  end


  def archive
    # archive the record
    ActiveRecord::Base.logger.debug "archiving reservation #{self.id}"
    return if self.id == 0
    # obscure credit card number in payments
    payments.each {|p| p.update_attributes :credit_card_no => p.credit_card_no_obscured}
    if Reason.close_reason != "abandoned"
      arc = Archive.archive_record(self)
      # ActiveRecord::Base.logger.debug "archiving complete"
      arc.close_reason = Reason.close_reason
      arc.save
      # ActiveRecord::Base.logger.debug "archive saved"
      reload
      update_attribute :archived, true
      add_log("Archived")
      # ActiveRecord::Base.logger.debug "archive flag set"
    elsif Reason.close_reason == "abandoned" && camper_id 
      arc = Archive.archive_record(self)
      arc.close_reason = Reason.close_reason
      arc.save
      add_log("Archived")
      self.destroy
    else # no camper
      self.destroy
    end
    # ActiveRecord::Base.logger.debug "reservation #{self.id} archived"
    # update the group
    begin
      if group_id != nil
	# ActiveRecord::Base.logger.debug "group is #{group_id}"
	group = Group.find(group_id)
	count = Reservation.count(:conditions => ["group_id = ? and archived = ?",group_id, false])
	# ActiveRecord::Base.logger.debug "present count of group is #{count}"
	group.update_attributes :expected_number => count
      end
    rescue ActiveRecord::RecordNotFound
      # ignore this error
      # ActiveRecord::Base.logger.debug "group #{group_id} not found"
    end
    # update camper activity
    # ActiveRecord::Base.logger.debug "updating camper #{camper.id}"
    camper.active if camper != nil
    # get rid of any space allocations for group reservations
    # ActiveRecord::Base.logger.debug "cleaning up space allocs"
    SpaceAlloc.delete_all(["reservation_id = ? ", id])
    # ActiveRecord::Base.logger.debug "done"
  rescue
    raise 'Archive failed'
  end

  def checkout(options, user_login = nil)
    if checked_in == true
      add_log('checkout')
      update_attribute :checked_out, true
      if user_login
        Reason.close_reason_is "checkout by: #{user_login} at: #{currentTime}"
      else
        Reason.close_reason_is "checkout at: #{currentTime} "
      end
      archive
    end
  end

  def due
    pmt = Payment.total(self.id)
    if (self.override_total > 0.0) && Option.first.use_override?
      self.override_total - pmt
    else
      self.total + self.tax_amount - pmt
    end
  end

  def get_charges (charges)
    self.days = charges.days
    self.daily_rate = charges.daily_rate
    self.daily_disc = charges.day_disc
    self.weeks = charges.weeks
    self.weekly_rate = charges.weekly_rate
    self.weekly_disc = charges.week_disc
    self.months = charges.months
    self.monthly_rate = charges.monthly_rate
    self.monthly_disc = charges.month_disc
    self.seasonal_rate = charges.seasonal_rate

    self.day_charges = charges.day_charges
    self.week_charges = charges.week_charges
    self.month_charges = charges.month_charges
    self.seasonal_charges = charges.seasonal_charges
    # ActiveRecord::Base.logger.info "charges are #{self.days} days #{self.day_charges} #{self.weeks} weeks #{self.week_charges} #{self.months} months #{self.month_charges}"

    self.discount_name = charges.discount_name
    self.discount_percent = charges.discount_percent
    self.ext_charges = charges.extra_charges
    self.total = self.day_charges + self.week_charges + self.month_charges +
		 self.ext_charges + self.seasonal_charges
  end

  def get_possible_dates(remote = false)
    ####################################################
    # given the reservation find how early or late the
    # camper can checkin to this space
    ####################################################
    if self.checked_in
      # if already checked in the startdate cannot be changed
      av_string = "<b>Only the checkout date can be changed, dates cannot span an unavailable date</b>"
    else
      av_string = "<b>Dates can be changed to any dates shown, dates cannot span an unavailable date</b>"
    end
  end

  ################################################
  # a method to check whether seasonal reservations
  # are permitted in this situation
  ################################################
  def check_seasonal
    if seasonal
      return true
    elsif storage
      return false
    else
      option = Option.first
      if option.use_seasonal?
        season = Season.find_by_date(option.season_start)
        rate = Rate.find_current_rate(season.id, space.price_id).seasonal_rate 
        # ActiveRecord::Base.logger.debug 'season is ' + season.name + ' season rate is ' + rate.to_s
        if rate > 0.001
          r = Reservation.all :conditions => ["id != ? AND space_id = ? AND ? < enddate AND ? >= startdate", id, space_id, option.season_start, option.season_end]
          return true if r.size == 0
        end
      end
    end
    return false
  rescue
    return true
  end

  def check_storage
    if storage
      return true
    elsif seasonal
      return false
    else
      option = Option.first
      if option.use_storage?
        season = Season.find_by_date(startdate)
        rate = Rate.find_current_rate(season.id, space.price_id).monthly_storage
        # ActiveRecord::Base.logger.debug 'season is ' + season.name + ' storage rate is ' + rate.to_s
        return true if rate > 0.001
      end
    end
    return false
  rescue
    return true
  end
  
  def onetime_formatted=(str)
    ###########################################
    # save the formatted value
    ###########################################
    self.onetime_discount = str.gsub(/[^0-9.]/,'').to_i
  end
  
  def onetime_formatted
    ###########################################
    # format the deposit for display
    ###########################################
    option = Option.first
    n = number_2_currency(onetime_discount)
    return n
  end

  def close_reason
    if log && log.include?('cancel') && archived
      a = Archive.find_by_reservation_id(id)
      if a
	(first,second) = a.close_reason.split('reason:')
        return second
      else
        ''
      end
    end
  end

  ###########################################
  # methods needed for migrations only
  ###########################################
  def _cancelled?
    if log && !log.empty?
      log_array = log.split('<br/>')
      log_array.reverse_each do |l|
	return false if l =~ /made|undo cancel|remote/
	return true if l =~ /cancel/
      end
    end
    return false
  end

  def _checked_out?
    if log && !log.empty?
      log_array = log.split('<br/>')
      log_array.reverse_each do |l|
	return false if l =~ /made|undo checkout|remote/
	return true if l =~ /checkout/
      end
    end
    return false
  end
  ###########################################
  # end methods needed for migrations only
  ###########################################

  private

  def manditory?
    if is_remote
      option = Option.first
      if option.use_remote_rig_type && option.require_rigtype && rigtype.name == 'Unknown'
	errors.add(:rigtype, "must be selected")
      end
      if option.use_remote_length && option.require_length && length == 0
        errors.add(:length, "must be entered")
      end
      if option.use_remote_age && option.require_age && rig_age == 0
        errors.add(:rig_age, "must be entered")
      end
    end
  end

  def no_conflict?
    sp = Space.confirm_available(id, space_id, startdate, enddate)
    if sp.size > 0
      logger.debug "Reservation#no_conflict? spaces found in conflict #{sp.inspect}"
      errors.add(:base, "This space & date conflicts with another reservation")
    end
  end

  def valid_dates?
    errors.add(:startdate, "not set") unless startdate
    errors.add(:enddate, "not set") unless enddate
    errors.add(:startdate, "after or equal to enddate") if startdate && enddate && (enddate <= startdate)
    return if confirm
    errors.add(:base, "..Campground closed for some or all of period") unless Campground.open?(startdate, enddate)
    if unconfirmed_remote
      Blackout.all.each do |b|
	if b.blacked_out? startdate, enddate
	  errors.add(:base, "dates #{b.startdate} to #{b.enddate} are blacked out, call for reservation")
	end
      end
    end
    # ActiveRecord::Base.logger.debug "validation error: #{errors.inspect}" if errors
  end
  
  def valid_camper?
    if confirm 
      unless camper_id?
        errors.add(:camper_id, "is missing")
      end
    end
  end
end
