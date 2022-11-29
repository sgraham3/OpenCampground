module RemoteHelper

  def blackout_dates
    str = ''
    Blackout.active.each {|b| str << "<div style=\"text-indent: 5em\">blacked out #{DateFmt.format_date(b.startdate,'long')} to #{DateFmt.format_date(b.enddate,'long')} for #{b.name}</div>"}
    if str.blank?
      return str
    else
      if @option.phone_home.blank?
	return '<div><b>Remote reservations are not availailable in blackout dates. Please call the office for help.' + str + '</div>'
      else
	return "<div><b>Remote reservations are not availailable in blackout dates. Please call the office at #{@option.phone_home} for help. #{str} </div>"
      end
    end
  end
      
  def deposit_details(dep)
    # logger.debug dep.inspect
    if dep[:custom] == 'Full'
      return "\n"
    else
      return "<tr><td>#{dep[:custom]}</td>#{spacing_for_charges}<td align=\"right\">" +
	      number_2_currency(dep[:charge]) + "</td></tr>\n"
    end
  end

  def payment_details(pmt)
    # cardtype number date [user] memo
    memo = pmt.memo? ? pmt.memo : ""
    card = pmt.creditcard_id? ? pmt.creditcard.name : ""
    # date = pmt.pmt_date ? DateFmt.format_date(pmt.pmt_date) : ""
    date = DateFmt.format_date(pmt.pmt_date,'long')

    card + ' ' + date + ' ' + memo
  end

  def fd_charges(res)
    # generate lines like
    # <input name="x_line_item" value="
    #                         Item ID<|>
    #                         Item Title<|>
    #			      Item Description<|>
    #			      Quantity<|>
    #			      Unit Price<|>
    #			      Taxable<|> Y or N
    #			      Product Code<|>
    #			      Commodity Code<|>
    #			      Unit of Measure<|>
    #			      Tax Rate<|>
    #			      Tax Type<|>
    #			      Tax Amount<|>
    #			      Discount Indicator<|>
    #			      Discount Amount<|>
    #			      Line Item Total" type="hidden">
    #
    str = ''
    counter = 0
    logger.debug "#{res.charges.size} charges"
    charges = 0.0
    res.charges.each do |chg|
      # Item ID
      counter += 1
      logger.debug counter.to_s
      str << '<input name="x_line_item" value = "' + counter.to_s + '<|>' 
      # Item Title and Item Description
      season_count = Season.count(:conditions => ["active = ?", true])
      case chg.charge_units
      when Charge::DAY
	str <<  chg.season.name + ' ' if season_count > 1
	str <<  I18n.t('reservation.Days') + ' ' + DateFmt.format_date(chg.start_date,'long') + '-' + DateFmt.format_date(chg.end_date,'long') + '<|>' 
	str <<  chg.season.name + ' ' if season_count > 1
	str <<  I18n.t('reservation.Days') + ' ' + DateFmt.format_date(chg.start_date,'long') + '-' + DateFmt.format_date(chg.end_date,'long') + '<|>' 
	logger.debug 'days'
      when Charge::WEEK
	str <<  chg.season.name + ' ' if season_count > 1
	str << I18n.t('reservation.Weeks') + ' ' + DateFmt.format_date(chg.start_date,'long') + '-' + DateFmt.format_date(chg.end_date,'long') + '<|>' 
	str <<  chg.season.name + ' ' if season_count > 1
	str << I18n.t('reservation.Weeks') + ' ' + DateFmt.format_date(chg.start_date,'long') + '-' + DateFmt.format_date(chg.end_date,'long') + '<|>' 
	logger.debug 'weeks'
      when Charge::MONTH
	str <<  chg.season.name + ' ' if season_count > 1
	str << I18n.t('reservation.Months') + ' ' + DateFmt.format_date(chg.start_date,'long') + '-' + DateFmt.format_date(chg.end_date,'long') + '<|>' 
	str <<  chg.season.name + ' ' if season_count > 1
	str << I18n.t('reservation.Months') + ' ' + DateFmt.format_date(chg.start_date,'long') + '-' + DateFmt.format_date(chg.end_date,'long') + '<|>' 
	logger.debug 'months'
      end
      # quantity
      str <<  sprintf("%0.2f", chg.period) + '<|>' 
      # unit price
      str << sprintf('%0.2f',chg.rate) + '<|>'
      # taxable?, product code, commodity code, unit of measure, tax rate, tax amount, discount indicator, discount amount
      str << 'N<|><|><|><|><|><|><|>0.00<|>'
      # line item total
      str << sprintf('%0.2f', chg.amount)
      str << '" type="hidden">' + "\n"
      charges += chg.amount
    end
    res.extra_charges.each do |ext|
      if ext.extra.extra_type == Extra::OCCASIONAL
	if ext.charge != 0.0
	  counter += 1
	  # Item ID
	  str << '<input name="x_line_item" value = "' + counter.to_s + '<|>' 
	  # Item Title and Item Description
	  str << ext.extra.name + '<|>' + ext.extra.name + '<|>'
	  # quantity
	  str << ext.number.to_s + '<|>'
	  # unit price
	  str << sprintf('%0.2f', ext.extra.charge) + '<|>'
	  # taxable?, product code, commodity code, unit of measure, tax rate, tax amount, discount indicator, discount amount
	  str << 'N<|><|><|><|><|><|><|>0.00<|>'
	  # line item total
	  str << sprintf('%0.2f', ext.charge) + '" type="hidden">' + "\n"
	  charges += ext.charge
	end
      else
        # Item Title and Item Description
        if ext.days > 0
          counter += 1
	  # Item ID
          str << '<input name="x_line_item" value = "' + counter.to_s + '<|>' 
          # Item Title and Item Description
          str << ext.extra.name + ' days' + '<|>' + ext.extra.name + ' days' + '<|>'
          # quantity
          if(ext.extra.extra_type == Extra::COUNTED) 
	    str << (ext.days * ext.number).to_s + '<|>'
	  else
	    str << ext.days.to_s  + '<|>'
	  end
          # unit price
          str << sprintf('%0.2f', ext.extra.daily) + '<|>'
          # taxable?, product code, commodity code, unit of measure, tax rate, tax amount, discount indicator, discount amount
          str << 'N<|><|><|><|><|><|><|>0.00<|>'
          # line item total
          str << sprintf('%0.2f', ext.daily_charges) + '" type="hidden">' + "\n"
          charges += ext.daily_charges
        end
        if ext.weeks > 0
          counter += 1
	  # Item ID
          str << '<input name="x_line_item" value = "' + counter.to_s + '<|>' 
          # Item Title and Item Description
          str << ext.extra.name + ' weeks' + '<|>' + ext.extra.name + ' weeks' + '<|>'
          # quantity
          if(ext.extra.extra_type == Extra::COUNTED) 
	    str << (ext.weeks * ext.number).to_s + '<|>'
	  else
	    str << ext.weeks.to_s  + '<|>'
	  end
          # unit price
          str << sprintf('%0.2f', ext.extra.weekly) + '<|>'
          # taxable?, product code, commodity code, unit of measure, tax rate, tax amount, discount indicator, discount amount
          str << 'N<|><|><|><|><|><|><|>0.00<|>'
          # line item total
          str << sprintf('%0.2f', ext.weekly_charges) + '" type="hidden">' + "\n"
          charges += ext.weekly_charges
        end
        if ext.months > 0
          counter += 1
	  # Item ID
          str << '<input name="x_line_item" value = "' + counter.to_s + '<|>' 
          # Item Title and Item Description
          str << ext.extra.name + ' months' + '<|>' + ext.extra.name + ' months' + '<|>'
          # quantity
          if(ext.extra.extra_type == Extra::COUNTED) 
	    str << (ext.months * ext.number).to_s + '<|>'
	  else
	    str << ext.months.to_s  + '<|>'
	  end
          # unit price
          str << sprintf('%0.2f', ext.extra.monthly) + '<|>'
          # taxable?, product code, commodity code, unit of measure, tax rate, tax amount, discount indicator, discount amount
          str << 'N<|><|><|><|><|><|><|>0.00<|>'
          # line item total
          str << sprintf('%0.2f', ext.monthly_charges) + '" type="hidden">' + "\n"
          charges += ext.monthly_charges
        end
      end
    end
    res.taxes.each do |t|
      counter += 1
      str << '<input name="x_line_item" value = "' + counter.to_s + '<|>' 
      # Item Title and Item Description
      str << t.name + '<|>'
      str << t.name + '<|>'
      # quantity
      str <<  '1.0<|>' 
      # unit price
      str << sprintf('%0.2f',t.amount) + '<|>'
      # taxable?, product code, commodity code, unit of measure, tax rate, tax amount, discount indicator, discount amount
      str <<  'N<|><|><|><|><|><|><|>0.00<|>'
      # line item total
      str << sprintf('%0.2f', t.amount)
      str << '" type="hidden">' + "\n"
      charges += t.amount
    end
    str << '<input name="x_amount" value="' + sprintf("%0.2f", charges) + '" type="hidden">' + "\n"
    hash = @integration.firstdatae4_hash(@reservation, charges)
    str << '<input name="x_fp_hash" value="' + hash + '" type="hidden">'
    logger.debug str
    return str
  end
  
end
