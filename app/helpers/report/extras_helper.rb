module Report::ExtrasHelper
  def ex_totals(charge)
    # charge is a extra_charge model instance
    
    option = Option.first
    output = String.new
    case @subtotal_on
    when 'None'
    when 'Reservation'
      debug "old res is #{@res}"
      if charge.reservation_id != @res
        if @subtotal != 0.0
	  case charge.extra.extra_type
	  when Extra::MEASURED
	    output << '<tr> <td>Subtotal</td> <td></td> <td></td> <td></td> <td></td> <td></td> <td></td> <td></td> <td align="right"><b>' +
		      number_2_currency(@subtotal) + '</b></td> </tr>'
	  when Extra::STANDARD
	    output << '<tr> <td>Subtotal</td> <td></td> <td></td> <td></td> <td></td> <td align="right"><b>' +
		      number_2_currency(@subtotal) + '</b></td> </tr>'
	  else
	    output << '<tr> <td>Subtotal</td> <td></td> <td></td> <td></td> <td></td> <td></td> <td align="right"><b>' +
		      number_2_currency(@subtotal) + '</b></td> </tr>'
	  end
	  @subtotal = 0.0
	end
	@res = charge.reservation_id
	debug "res is now #{@res}"
      end
    when 'Week'
	debug "old week is #{@week}"
      if charge.updated_on.cweek != @week 
        if @subtotal != 0.0
	  case charge.extra.extra_type
	  when Extra::MEASURED
	    output << '<tr> <td>Subtotal</td> <td></td> <td></td> <td></td> <td></td> <td></td> <td></td> <td></td> <td align="right"><b>' +
		      number_2_currency(@subtotal) + '</b></td> </tr>'
	  when Extra::STANDARD
	    output << '<tr> <td>Subtotal</td> <td></td> <td></td> <td></td> <td></td> <td align="right"><b>' +
		      number_2_currency(@subtotal) + '</b></td> </tr>'
	  else
	    output << '<tr> <td>Subtotal</td> <td></td> <td></td> <td></td> <td></td> <td></td> <td align="right"><b>' +
		      number_2_currency(@subtotal) + '</b></td> </tr>'
	  end
	  @subtotal = 0.0
	end
	@week = charge.updated_on.cweek
	debug "week is now #{@week}"
      end
    when 'Month'
	debug "old month is #{@month}"
      if charge.updated_on.month != @month
	debug 'new month'
        if @subtotal != 0.0
	  case charge.extra.extra_type
	  when Extra::MEASURED
	    output << '<tr> <td>Subtotal</td> <td></td> <td></td> <td></td> <td></td> <td></td> <td></td> <td></td> <td align="right"><b>' +
		      number_2_currency(@subtotal) + '</b></td> </tr>'
	  when Extra::STANDARD
	    output << '<tr> <td>Subtotal</td> <td></td> <td></td> <td></td> <td></td> <td align="right"><b>' +
		      number_2_currency(@subtotal) + '</b></td> </tr>'
	  else
	    output << '<tr> <td>Subtotal</td> <td></td> <td></td> <td></td> <td></td> <td></td> <td align="right"><b>' +
		      number_2_currency(@subtotal) + '</b></td> </tr>'
	  end
	  @subtotal = 0.0
	end
	@month = charge.updated_on.month
	debug "month is now #{@month}"
      end
    end
    @total += charge.charge
    @subtotal += charge.charge
    debug "subtotal is #{@subtotal} and total is #{@total}"
    output
  end
end
