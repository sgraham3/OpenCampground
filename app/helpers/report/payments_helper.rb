module Report::PaymentsHelper
  def payments_by_res(res_id, start_at = Time.local(0), end_at = Time.now)
    pmt = 0.0
    t_net = 0.0
    t_tax = 0.0
    p = Payments.all(:conditions => ["RESERVATION_ID = ? AND pmt_date >= ? AND pmt_date <= ?",
				  res_id, start_at, end_at])
    p.each do |p|
      pmt += p.amount
      net,tax = p.taxes
      t_net += net
      t_tax += tax
    end
    return pmt, t_net, t_tax
  end

  def p_if_needed(pmt)
    if pmt.reservation_id == @res
      debug "reservation #{@res.to_i}"
      # already have res.  Do not print res info
      "<td></td> <td></td> <td></td> <td></td>"
    else
      # new res...print out info
      if pmt.reservation_id
	@res = pmt.reservation_id
	begin
	  res = Reservation.find @res
	  name = res.camper.full_name
	  space_name = res.space.name
	  space_type = res.space.sitetype.name
	rescue
	  arch = Archive.find_by_reservation_id @res
	  name = arch.name
	  space_name = arch.space_name
	  space_type = ''
	end
	"<td>#{pmt.reservation_id}</td><td>#{name}</td><td>#{space_name}</td><td>#{space_type}</td>"
      else
	"<td colspan=\"2\">Reservation unknown: pmt_date " + pmt.pmt_date.strftime("%H%M") + " </td>"
      end
    end
  end

  def output_subtotal
    str = "<td></td><td></td> <td></td> <td></td> <td></td> <td></td><td align=\"right\"><b>#{number_2_currency(@net_sub)}</b></td>"
    str << "<td align=\"right\"><b>#{number_2_currency(@tax_sub)}</b></td>"
    str << "<td align=\"right\"><b>#{number_2_currency(@subtotal)}</b></td></tr><tr>"
    @subtotal = 0.0
    @net_sub = 0.0
    @tax_sub = 0.0
    str
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
	str = '<td><b>Subtotal</b></td> <td></td>'
	str << output_subtotal
	# @res = pmt.reservation_id if pmt
      end
    when 'Week'
      debug 'in Week'
      if !pmt || pmt.pmt_date.to_date.cweek != @week
        debug 'new week'
	str = "<td><b>Subtotal</b></td> <td>week ##{@week}</td>"
	str << output_subtotal
	@week = pmt.pmt_date.to_date.cweek if pmt
	@res = 0
      end
    when 'Month'
      debug "in Month (#{@month}) subtotal is #{number_2_currency(@subtotal)}"
      if !pmt || pmt.pmt_date.to_date.month != @month
        last_month = @dt
	debug "new month subtotal is #{number_2_currency(@subtotal)}"
	@dt = pmt.pmt_date.to_date if pmt
	if last_month == 0
	  str = "<td><b>Subtotal</b></td><td></td>"
	else
	  str = "<td><b>Subtotal</b></td><td>#{last_month.strftime("%B %Y")}</td>"
	end
	str << output_subtotal
	@month = @dt.month if pmt
	@res = 0
	debug "month now is #{@month}"
      end
    when 'Payment Type'
      debug "in Payment Type (#{@card}, #{@cardname}) subtotal is #{number_2_currency(@subtotal)}"
      if !pmt || pmt.creditcard_id != @card
	debug "subtotaling: card is #{@card}"
        # @cardname = pmt.creditcard.name unless @cardname
	str = "<td><b>Subtotal</b></td> <td>#{@cardname}</td>"
	str << output_subtotal
	@card = pmt.creditcard_id if pmt
	@cardname = pmt.creditcard.name if pmt
	debug "card now is #{@card}"
	@res = 0
      end
    else
      debug 'missing sort'
    end 
    str
  end

  def total(tot = 0.0, net = 0.0, tax = 0.0)
      str = "<td><b>Total</b></td><td></td><td></td><td></td><td></td><td></td><td></td><td></td><td align=\"right\"><b>#{number_2_currency(net)}</b></td> <td align=\"right\"><b>#{number_2_currency(tax)}</b></td> <td align=\"right\"><b>#{ number_2_currency(tot) }</b></td>"
  end
end
