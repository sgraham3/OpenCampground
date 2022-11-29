module ReservationHelper
  include MyLib

  # for res list set class
  def check_rl_status(res)
    if res.startdate < currentDate
       str = '<tr class="late_checkin">'
    elsif res.startdate == currentDate
       str = '<tr class="today_checkin">'
    else
      str = '<tr>'
    end
  end

  # for in park list set class
  def check_ip_status(res)
    if res.enddate < currentDate
      str = '<tr class="overstay">'
    elsif res.enddate == currentDate
      if @option.use_checkout_time?
	checkout_time = currentDate.at_midnight +
		  @option.checkout_time.seconds_since_midnight
        if currentTime > checkout_time
	  str = '<tr class="overstay">'
	else
	  str = '<tr class="today_checkout">'
	end
      else
	str = '<tr class="today_checkout">'
      end
    else
      str = '<tr>'
    end
  end

  def payment_details(pmt)
    # cardtype number date [user] memo
    id = "\##{pmt_id(pmt)} "
    #logger.logger.debug "memo is " + memo
    card = pmt.creditcard_id? ? pmt.creditcard.name : ""
    #logger.debug "card is " + card
    # date = pmt.pmt_date ? DateFmt.format_date(pmt.pmt_date) : ""
    date = DateFmt.format_date(pmt.pmt_date,'long')
    #logger.debug "date is " + date
    if pmt.name == "" || pmt.name == nil
      name = ""
    else
      name = " [" + pmt.name + "]"
    end
    #logger.debug "name is " + name
    number = " <span class=\"noprint\">#{pmt.credit_card_no}</span> "
    #logger.debug "number is " + number
    exp = pmt.cc_expire ? "<span class=\"noprint\">exp #{pmt.cc_expire.strftime("%m/%y")}</span> " : ""

    if pmt.memo?
      id + card + number + exp + date + name + " " + pmt.memo
    else
      id + card + number + exp + date + name
    end
  end

  def override_button(override = 0.0)
    if @option.use_override
      if !@option.use_login? || @user_login.admin? || @option.override_by_all?
        if override == 0.0
          "<td>" + button_to(I18n.t('reservation.OverrideTotal'), :action => :get_override) + "</td>"
        else
          "<td>" + button_to(I18n.t('reservation.CancelOverride'), {:action => :cancel_override, :id =>@reservation.id}) + "</td>"
        end
      end
    end
  end

  def amount_due
    if @reservation.cancelled?
      due = @reservation.cancel_charge - @pmt
    else
      if @option.use_override? && @reservation.override_total > 0.0
	due = @reservation.override_total - @pmt
      else
	due = @reservation.total + @reservation.tax_amount - @pmt
      end
    end
    number_2_currency(due)
  end

end
