class Payment < ActiveRecord::Base
  include MyLib

  belongs_to :creditcard
  belongs_to :reservation
  has_one    :card_transaction, :dependent => :delete
  has_one    :paypal_transaction, :dependent => :delete
  validates_presence_of :reservation_id

  # a virtual method for subtotal
  def subtotal
    @subtotal
  end

  def subtotal=(st)
    @subtotal = st
  end

  def before_save
    self.amount = 0.0 if self.amount.nil?
    self.cc_fee = 0.0 if self.cc_fee.nil?
    self.creditcard_id = 1 unless self.creditcard_id
    if defined? self.pmt_date
      self.pmt_date = currentDate unless self.pmt_date
    end
  end

  def self.total(res_id)
    tot = 0.0
    find_all_by_reservation_id(res_id).each { |p| tot += p.amount}
    return tot
  end

  def credit_card_no_obscured
    return "xxxxxxxx#{credit_card_no.slice(-4, 4)}" if credit_card_no && credit_card_no.length > 4
    credit_card_no
  end

  def taxes
    ###########################################
    # compute what portion of the charges
    # return the amount split into tax and net 
    ###########################################
    if (reservation.total + reservation.tax_amount) == amount
      ActiveRecord::Base.logger.debug "payment is full amount #{amount}"
      net = reservation.total
      tax = reservation.tax_amount
      ActiveRecord::Base.logger.debug "tax is #{tax} net is #{net}"
    elsif reservation.tax_amount > 0.0
      ActiveRecord::Base.logger.debug "tax amount is #{reservation.tax_amount} and total is #{reservation.total}"
      tax_rate = reservation.tax_amount.to_f/reservation.total.to_f
      ActiveRecord::Base.logger.debug "tax_rate is #{tax_rate} and amount is #{amount}"
      net = (amount.to_f/ (1.0 + tax_rate))
      tax = amount - net
      ActiveRecord::Base.logger.debug "tax is #{tax} net is #{net}"
    else # tax is <= 0.0
      ActiveRecord::Base.logger.debug "tax is <= 0 #{tax}"
      net = amount
      tax = 0.0
      ActiveRecord::Base.logger.debug "tax is #{tax} net is #{net}"
    end
    return net, tax
  rescue
    return amount, 0.0
  end
  
  private

  def exp_str
    if self.cc_expire
      self.cc_expire.strftime("%m/%y")
    else
      currentDate.strftime("%m/%y")
    end
  end

  def exp_str=(str)
    m,y = str.split /\//
    self.cc_expire = Date.new(y.to_i+2000, m.to_i, 1)
  rescue
    # in case the Date blows up do nothing
  end

  def amount_formatted=(str)
    ###########################################
    # save the formatted value
    ###########################################
    self.amount = str.gsub(/[^0-9.]/,'').to_i
  end

  def amount_formatted
    ###########################################
    # format the amount for display
    ###########################################
    option = Option.first
    n = number_2_currency(amount)
    return n
  end

  def deposit_formatted=(str)
    ###########################################
    # save the formatted value
    ###########################################
    self.deposit = str.gsub(/[^0-9.]/,'').to_i
  end
  
  def deposit_formatted
    ###########################################
    # format the deposit for display
    ###########################################
    option = Option.first
    n = number_2_currency(amount)
    return n
  end

  def self.tp(startdate, enddate, sort)
    @payments = all(:conditions => ["pmt_date >= ? AND pmt_date < ?",
				    startdate.to_datetime.at_midnight,
				    enddate.tomorrow.to_datetime.at_midnight],
		    :include => ['reservation','creditcard'],
		    :order => 'reservation_id')
    csv_string = '"Customer","Date","Item","Amount","Sale Number"'
    csv_string << "\n"
    total = 0.0
    @payments.each do |p|
      date = p.pmt_date.strftime("%m/%d/%Y")
      net,tax = p.taxes
      # debug p.creditcard.inspect
      begin
	res = Reservation.find p.reservation_id
	# debug "reservation #{p.reservation_id} found"
	name = res.camper.full_name
      rescue
	# debug "reservation #{p.reservation_id} not found"
	name = Archive.find_by_reservation_id(p.reservation_id).name
      end
      csv_string << "\"#{p.reservation.camper.last_name},#{p.reservation.camper.first_name}\",#{date},\"#{p.reservation.space.name}\",\"#{p.amount.round(2)}\",\"#{p.reservation.id}\"\n"
    end
    return csv_string
  end

  def self.qif(startdate, enddate, sort)
    @payments = all(:conditions => ["pmt_date >= ? AND pmt_date < ?",
				    startdate.to_datetime.at_midnight,
				    enddate.tomorrow.to_datetime.at_midnight],
		    :include => ['reservation','creditcard'],
		    :order => 'reservation_id')
    csv_string << ""
    total = 0.0
    @payments.each do |p|
      date = p.pmt_date.strftime("%m/%d/%Y")
      net,tax = p.taxes
      # debug p.creditcard.inspect
      begin
	res = Reservation.find p.reservation_id
	# debug "reservation #{p.reservation_id} found"
	name = res.camper.full_name
      rescue
	# debug "reservation #{p.reservation_id} not found"
	name = Archive.find_by_reservation_id(p.reservation_id).name
      end
      # csv_string << "\"#{pmt_id(p)}\", #{p.reservation_id},\"#{name}\",#{p.reservation.space.name},#{p.reservation.space.sitetype.name}\",\"#{p.creditcard.name}\",#{date},\"#{p.memo}\",#{net.round(2)},#{tax.round(2)},#{p.amount.round(2)}\n"
    end
    return csv_string
  end

  def self.csv(startdate, enddate, sort)
    @payments = all(:conditions => ["pmt_date >= ? AND pmt_date < ?",
				    startdate.to_datetime.at_midnight,
				    enddate.tomorrow.to_datetime.at_midnight],
		    :include => ['reservation','creditcard'],
		    :order => 'reservation_id')
    if startdate == enddate
      csv_string = "\"Payments\", #{startdate}\n"
    else
      csv_string = "\"Payments\", #{startdate}, \"thru\", #{enddate}\n"
    end
    csv_string << '"ID","Res #","Camper","Space Name","Sitetype","Pmt Type","Date","Memo","Charges","Tax","Total"'
    csv_string << "\n"
    total = 0.0
    @payments.each do |p|
      date = p.pmt_date.strftime("%m/%d/%Y")
      net,tax = p.taxes
      # debug p.creditcard.inspect
      begin
	res = Reservation.find p.reservation_id
	# debug "reservation #{p.reservation_id} found"
	name = res.camper.full_name
      rescue
	# debug "reservation #{p.reservation_id} not found"
	name = Archive.find_by_reservation_id(p.reservation_id).name
      end
      csv_string << "\"#{p.created_at.to_i.to_s }\", #{p.reservation_id},\"#{name}\",\"#{p.reservation.space.name}\",\"#{p.reservation.space.sitetype.name}\",\"#{p.creditcard.name}\",#{date},\"#{p.memo}\",#{net.round(2)},#{tax.round(2)},#{p.amount.round(2)}\n"
    end
    return csv_string
  end

  def self.bsa(startdate, enddate, sort)
    @payments = all(:conditions => ["pmt_date >= ? AND pmt_date < ?",
				    startdate.to_datetime.at_midnight,
				    enddate.tomorrow.to_datetime.at_midnight],
		    :include => ['reservation','creditcard'],
		    :order => 'reservation_id')
    csv_string = ""
    # csv_string << '"Post Date", "Reciept Item Code", "Reference #", "GL number Debit", "GL number Credit", "Amount", "Paid by", "Tender type code"'
    # csv_string << "\n"
    total = 0.0
    @payments.each do |p|
      date = p.pmt_date.strftime("%m/%d/%Y")
      net,tax = p.taxes
      # debug p.creditcard.inspect
      begin
	res = Reservation.find p.reservation_id
	name = res.camper.full_name
      rescue
	# debug "reservation #{p.reservation_id} not found"
	name = Archive.find_by_reservation_id(p.reservation_id).name
      end
      csv_string << "#{p.updated_at.strftime("%m/%d/%Y")},\"OCG\",\"#{p.reservation_id}\",,,#{p.amount.round(2)},\"#{name}\",\"#{p.creditcard.name}\"\n"
    end
    return csv_string
  end
end
