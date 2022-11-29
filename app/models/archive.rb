class Archive < ActiveRecord::Base
  extend MyLib

  serialize :extras
  serialize :payments

  def reservation_available?
    Reservation.find reservation_id
    option = Option.first
    if option.edit_archives
      if option.use_login?
	if User.find(User.current).admin
	  logger.debug 'reservation_available? 2: admin'
	  return true
	elsif option.all_edit_archives
	  logger.debug 'reservation_available? 3: user permitted'
	  return true
	else
	  logger.debug 'reservation_available? 4: no admin permissions'
	  return false
	end
      else
	logger.debug 'reservation_available? 5: login not used'
	return true
      end
    else
      logger.debug 'reservation_available? 6: archive not editable'
      return false
    end
  rescue 
    logger.debug 'reservation_available? 6: reservation not available'
    return false
  end

  def self.archive_record(res)
    ####################################################
    # archive reservation contained in res
    # return Archive object
    ####################################################
    option = Option.first
    archive_rec = new do |a|
      a.canceled = currentDate
      if res.camper_id? 
	a.reservation_id = res.id
	a.name = res.camper.last_name+', '+res.camper.first_name
	a.address = res.camper.address
	a.address2 = res.camper.address2
	a.city = res.camper.city
	a.state = res.camper.state
	a.mail_code = res.camper.mail_code
	a.phone = res.camper.phone
	a.email = res.camper.email
	a.country = res.camper.country_id? && res.camper.country.name? ? res.camper.country.name : ''
      end
      a.adults = res.adults
      a.pets = res.pets
      a.kids = res.kids
      a.discount_name = res.discount_id? ?  res.discount.name : ''
      a.seasonal = res.seasonal
      a.startdate = res.startdate
      a.enddate = res.enddate
      # ActiveRecord::Base.logger.debug "saving tax_str: #{res.tax_str}"
      a.tax_str = res.tax_str
      # get extras
      a.extras = ExtraCharge.find_all_by_reservation_id(res.id)
      ###################
      # get payments
      pmt_array = []
      res.payments.each do |pmt|
	# ActiveRecord::Base.logger.info "processing #{pmt.id}"
	am = pmt.amount.to_s
	# ActiveRecord::Base.logger.info "amount is #{am}"
	amount = number_2_currency(pmt.amount)
	# amount = number_2_currency(am)
	# amount = pmt.amount
	# ActiveRecord::Base.logger.info "formatted to #{amount}"
	memo = pmt.memo? ? pmt.memo : ""
	# ActiveRecord::Base.logger.info "got memo #{memo}"
	card = pmt.creditcard_id? ? pmt.creditcard.name : ""
	# ActiveRecord::Base.logger.info "got name #{card}"
	date = DateFmt.format_date pmt.created_at.to_date, 'long'
	# date = pmt.created_at.to_date.to_s
	# ActiveRecord::Base.logger.info "got date #{date}"
	if pmt.name == "" || pmt.name == nil
	  name = ""
	else
	  name = " [" + pmt.name + "]"
	end
	# ActiveRecord::Base.logger.info "got name #{name}"
	cc_no = pmt.credit_card_no_obscured
	pmt_array << "<tr><td>#{amount}</td><td>#{card}</td><td>#{cc_no}</td><td>#{date}</td><td>#{name}</td><td>#{memo}</td></tr>"
      end
      a.payments = pmt_array
      ###################
      a.deposit = res.deposit
      a.total_charge = res.override_total > 0.0 ?  res.override_total : res.total
      a.special_request = res.special_request
      a.log = res.log
      a.slides = res.slides
      a.length = res.length
      a.rig_age = res.rig_age
      a.vehicle_license = res.vehicle_license
      a.vehicle_state = res.vehicle_state
      a.vehicle_license_2 = res.vehicle_license_2
      a.vehicle_state_2 = res.vehicle_state_2
      a.rigtype_name = res.rigtype_id? ?  res.rigtype.name : ''
      a.space_name = res.space_id? ?  res.space.name : ''
      a.group_name = res.group_id? ?  res.group.name : ''
      a.recommender = res.recommender_id? ? res.recommender.name : ''
    end
  end   
  
  def self.fake_archive(res)
    ####################################################
    # create a partial archive record for display
    # return Archive object
    ####################################################
    archive_rec = new do |a|
      a.close_reason = 'Archive deleted'
      a.startdate = res.startdate
      a.enddate = res.enddate
      a.special_request = res.special_request
      a.rigtype_name = res.rigtype_id? ?  res.rigtype.name : ' '
      a.space_name = res.space_id? ?  res.space.name : ' '
    end
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

  def last_log_reason
    if log && !log.empty?
      arr = log.split('<br/>').reverse
      ActiveRecord::Base.logger.debug arr[0]
      r =  arr[0].split(' ')
      case r[0]
      when 'group'
        return "#{r[0]} #{r[1]}"
      when 'cancelled', 'checkout', 'abandoned'
        return r[0]
      when 'remote'
        return "#{r[0]} #{r[1]} #{r[2]} #{r[3]}"
      end
    end
    return close_reason.split(' ')[0]
  end

  def self.by_name( name_to_find )
    all( :conditions => ['LOWER(name) LIKE ?', "%#{name_to_find}%"], :order => :name)
  end
  
end
