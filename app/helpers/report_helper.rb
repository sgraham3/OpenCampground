module ReportHelper

  def header_occ(hdr)
    str = ""
    hdr.each do |h|
      str << '<td align="center">'
      str << h
      str << '</td>'
    end
    return str
  end

  def total_occ(occ)
    total = 0
    occ.each {|o| total += o}
    return total
  end

  def payment(res)
    _pmt = Payment.total(res.id)
    if @option.use_override && (res.override_total > 0.0)
      _total = res.override_total
    else
      _total = res.total + res.tax_amount
    end
    _due = _total - _pmt
    pmt = number_2_currency(_pmt)
    due = number_2_currency(_due)
    total = number_2_currency(_total)
    return pmt, due, total
  end

  def payments_by_res(res_id, start_at = Time.local(0), end_at = Time.now)
    pmt = 0.0
    p = Payments.all(:conditions => ["RESERVATION_ID = ? AND pmt_date >= ? AND pmt_date <= ?",
				  res_id, start_at, end_at])
    p.each do |p|
      pmt += p.amount
    end
    return pmt
  end

  def p_if_needed(pmt)
    if pmt.reservation_id == @res
      debug "reservation #{@res.to_i}"
      # already have res.  Do not print res info
      "<td></td> <td></td>"
    else
      # new res...print out info
      if pmt.reservation_id
	@res = pmt.reservation_id
	"<td>#{pmt.reservation_id}</td><td>#{pmt.reservation.camper.full_name}</td>"
      else
	"<td colspan=\"2\">Reservation unknown: pmt_date " + pmt.pmt_date.strftime("%H%M") + " </td>"
      end
    end
  end

  def sub_total(pmt = nil)
    debug "sub_total with sort #{@sort} count is #{@count} first time is #{@first_time.to_s}"
    case @sort
    when 'None' 
      debug 'in None'
    when 'Reservation'
      debug 'in Reservation'
      if !pmt || pmt.reservation_id != @res
	debug 'new reservation'
	str = '<td><b>Subtotal</b></td> <td></td> <td></td> <td></td> <td></td> <td></td> <td align="right">'
	str << "<b>#{number_2_currency(@subtotal)}</b></td></tr><tr>"
	# @res = pmt.reservation_id if pmt
	@subtotal = 0.0
      end
    when 'Week'
      debug 'in Week'
      if !pmt || pmt.pmt_date.to_date.cweek != @week
        debug 'new week'
	str = '<td><b>Subtotal</b></td> <td></td> <td></td> <td></td> <td></td> <td></td> <td align="right">'
	str << "<b>#{number_2_currency(@subtotal)}</b></td></tr><tr>"
	@subtotal = 0.0
	@week = pmt.pmt_date.to_date.cweek if pmt
      end
    when 'Month'
      debug "in Month (#{@month}) subtotal is #{number_2_currency(@subtotal)}"
      if !pmt || pmt.pmt_date.to_date.month != @month
	debug "new month subtotal is #{number_2_currency(@subtotal)}"
	str = '<td><b>Subtotal</b></td> <td></td> <td></td> <td></td> <td></td> <td></td> <td align="right">'
	str << "<b>#{number_2_currency(@subtotal)}</b></td></tr><tr>"
	@subtotal = 0.0
	@month = pmt.pmt_date.to_date.month if pmt
	debug "month now is #{@month}"
      end
    when 'Payment Type'
      debug "in Payment Type (#{@card}, #{@cardname}) subtotal is #{number_2_currency(@subtotal)}"
      if !pmt || pmt.creditcard_id != @card
	debug "subtotaling: card is #{@card}"
        # @cardname = pmt.creditcard.name unless @cardname
	str = "<td><b>Subtotal</b></td> <td>#{@cardname}</td>"
	str << '</td> <td></td> <td></td> <td></td> <td align="right">'
	str << "<b>#{number_2_currency(@subtotal)}</b></td></tr><tr>"
	@subtotal = 0.0
	@card = pmt.creditcard_id if pmt
	@cardname = pmt.creditcard.name if pmt
	debug "card now is #{@card}"
      end
    else
      debug 'missing sort'
    end 
    str
  end

  def ex_totals(charge)
    option = Option.first
    output = String.new
    case @subtotal_on
    when 'None'
    when 'Reservation'
      if charge.reservation_id != @res
        if @subtotal != 0.0
	  output << '<tr><td>Subtotal</td> <td></td> <td></td> <td></td> <td></td> <td></td> <td></td> <td></td> <td align="right"><b>' +
		    number_2_currency(@subtotal) + '</b></td> </tr>'
	  @subtotal = 0.0
	end
	@res = charge.reservation_id
      end
    when 'Week'
      if charge.updated_on.cweek != @week 
        if @subtotal != 0.0
	  output << '<tr> <td>Subtotal</td> <td></td> <td></td> <td></td> <td></td> <td></td> <td></td> <td></td> <td align="right"><b>' +
		    number_2_currency(@subtotal) + '</b></td> </tr>'
	  @subtotal = 0.0
	end
	@week = charge.updated_on.cweek
      end
    when 'Month'
      unless charge.updated_on.month != @month
        if @subtotal != 0.0
	  output << '<tr> <td>Subtotal</td> <td></td> <td></td> <td></td> <td></td> <td></td> <td></td> <td></td> <td align="right"><b>' +
		    number_2_currency(@subtotal) + '</b></td> </tr>'
	  @subtotal = 0.0
	end
	@month = charge.updated_on.month
      end
    end
    @total += charge.charge
    @subtotal += charge.charge
    output
  end

end
