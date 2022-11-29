module Setup::PricesHelper

  def each_season_rate(s)
    ret_str = String.new
    Price.all.each do |p|
      ret_str << "<tr> <td>#{p.name}</td>"
      rate = Rate.find_by_season_id_and_price_id(s.id,p.id)
      if @option.variable_rates?
	ret_str << "<td>#{ show_rate(rate.sunday,s.id, p.id)}</td>"
	ret_str << "<td>#{ show_rate(rate.monday,s.id, p.id)}</td>"
	ret_str << "<td>#{ show_rate(rate.tuesday,s.id, p.id)}</td>"
	ret_str << "<td>#{ show_rate(rate.wednesday,s.id, p.id)}</td>"
	ret_str << "<td>#{ show_rate(rate.thursday,s.id, p.id)}</td>"
	ret_str << "<td>#{ show_rate(rate.friday,s.id, p.id)}</td>"
	ret_str << "<td>#{ show_rate(rate.saturday,s.id, p.id)}</td>"
      else
	if rate
	  logger.debug "s.id is #{s.id}"
	  logger.debug "p.id is #{p.id}"
	  logger.debug "rate.id is #{rate.id}"
	  ret_str << "<td>#{ show_rate(rate.daily_rate,s.id, p.id)}</td>"
	else
	  # handle error condition where there is no rate
	  ret_str << "<td>#{ show_rate(0,s.id, p.id)}</td>"
	end
      end
      if rate
	ret_str << "<td> #{ show_rate(rate.weekly_rate,s.id, p.id)}</td>"
	ret_str << "<td> #{ show_rate(rate.monthly_rate,s.id, p.id)}</td>"
	ret_str << "<td> #{ show_rate(rate.seasonal_rate,s.id, p.id)}</td>" if @seasonal
	ret_str << "<td> #{ show_rate(rate.monthly_storage,s.id, p.id)}</td>" if @storage
      else
	# handle error condition where there is no rate
	ret_str << "<td> #{ show_rate(0,s.id, p.id)}</td>"
	ret_str << "<td> #{ show_rate(0,s.id, p.id)}</td>"
	ret_str << "<td> #{ show_rate(0,s.id, p.id)}</td>" if @seasonal
	ret_str << "<td> #{ show_rate(0,s.id, p.id)}</td>" if @storage
      end
      ret_str << "<td>" +  link_to('Delete', setup_price_path(p.id), 
					       :confirm => "Are you sure you want to delete #{p.name}?",
					       :method => :delete)  + "</td>"
      ret_str << "</tr>\n"
    end
    return ret_str
  end
    
  def all_rates
    ret_str = ''
    Price.all.each do |p|
      ret_str << "<tr> <td>#{p.name}</td>"
      @seasons.each do |s|
	rate = Rate.find_by_season_id_and_price_id(s.id,p.id)
	if @option.variable_rates?
	  ret_str << "<td>#{show_rate(rate.sunday,s.id, p.id)}</td>"
	  ret_str << "<td>#{show_rate(rate.monday,s.id, p.id)}</td>"
	  ret_str << "<td>#{ show_rate(rate.tuesday,s.id, p.id)}</td>"
	  ret_str << "<td>#{ show_rate(rate.wednesday,s.id, p.id)}</td>"
	  ret_str << "<td>#{ show_rate(rate.thursday,s.id, p.id)}</td>"
	  ret_str << "<td>#{ show_rate(rate.friday,s.id, p.id)}</td>"
	  ret_str << "<td>#{ show_rate(rate.saturday,s.id, p.id)}</td>"
	else
	  if rate
	    logger.debug "s.id is #{s.id}"
	    logger.debug "p.id is #{p.id}"
	    logger.debug "rate.id is #{rate.id}"
	    ret_str << "<td>#{ show_rate(rate.daily_rate,s.id, p.id)}</td>"
	  else
	    # handle error condition where there is no rate
	    ret_str << "<td>#{ show_rate(0,s.id, p.id)}</td>"
	  end
	end
	if rate
	  ret_str << "<td> #{ show_rate(rate.weekly_rate,s.id, p.id)}</td>"
	  ret_str << "<td> #{ show_rate(rate.monthly_rate,s.id, p.id)}</td>"
	  ret_str << "<td> #{ show_rate(rate.seasonal_rate,s.id, p.id)}</td>" if @seasonal
	  ret_str << "<td> #{ show_rate(rate.monthly_storage,s.id, p.id)}</td>" if @storage
	else
	  # handle error condition where there is no rate
	  ret_str << "<td> #{ show_rate(0,s.id, p.id)}</td>"
	  ret_str << "<td> #{ show_rate(0,s.id, p.id)}</td>"
	  ret_str << "<td> #{ show_rate(0,s.id, p.id)}</td>" if @seasonal
	  ret_str << "<td> #{ show_rate(0,s.id, p.id)}</td>" if @storage
	end
      end
      ret_str << "<td>" +  link_to('Delete', setup_price_url, :id => p.id, :action => :delete,
					       :confirm => "Are you sure you want to delete #{p.name}?",
					       :method => 'post')  + "</td>"
      ret_str << "</tr>\n"
    end
    return ret_str
  end

  def one_rate
    ret_str = "<table>"
    @seasons.each do |s|
      if @option.variable_rates 
	ret_str << "<tr><td>Sunday:</td> <td>" +    text_field('rate', 'sunday', :size => 8) + "</td> </tr>"
	ret_str << "<tr><td>Monday:</td> <td>" +    text_field('rate', 'monday', :size => 8) + "</td> </tr>"
	ret_str << "<tr><td>Tuesday:</td> <td>" +   text_field('rate', 'tuesday', :size => 8) + "</td> </tr>"
	ret_str << "<tr><td>Wednesday:</td> <td>" + text_field('rate', 'wednesday', :size => 8) + "</td> </tr>"
	ret_str << "<tr><td>Thursday:</td> <td>" +  text_field('rate', 'thursday', :size => 8) + "</td> </tr>"
	ret_str << "<tr><td>Friday:</td> <td>" +    text_field('rate', 'friday', :size => 8) + "</td> </tr>"
	ret_str << "<tr><td>Saturday:</td> <td>" +  text_field('rate', 'saturday', :size => 8) + "</td> </tr>"
      else 
	ret_str << "<tr><td>Daily rate:</td><td>" + text_field('rate', 'daily_rate', :size => 8) + "</td></tr>"
      end 
      ret_str << "<tr><td>Weekly rate:</td><td>" + text_field('rate', 'weekly_rate', :size => 10) + "</td></tr>"
      ret_str << "<tr><td>Monthly rate:</td><td>" + text_field('rate', 'monthly_rate', :size => 12) + "</td></tr>"
      ret_str << "<tr><td>Seasonal rate:</td><td>" + text_field('rate', 'seasonal_rate', :size => 14) + "</td></tr>" if @option.use_seasonal == true 
      ret_str << "<tr><td>Monthly Storage rate:</td><td>" + text_field('rate', :monthly_storage, :size => 14) + "</td></tr>" if @option.use_storage? 
      ret_str << "</table>\n"
    end
    return ret_str
  end

  def show_rate(rate, season_id, price_id)
    if rate > 0.0 
      if @option.rates_decimal.to_int > 2
	fmt = '%6.' + @option.rates_decimal.to_s + 'f'
	"<form method=\"get\" action=\"#{edit_setup_price_path(price_id)}\" class=\"button-to\"><div><input type=\"hidden\" name=\"season_id\" value=\"#{season_id}\"/><input type=\"submit\" value=\"#{sprintf(fmt, rate)}\" /></div></form>"
      else
	"<form method=\"get\" action=\"#{edit_setup_price_path(price_id)}\" class=\"button-to\"><div><input type=\"hidden\" name=\"season_id\" value=\"#{season_id}\"/><input type=\"submit\" value=\"#{number_2_currency(rate)}\" /></div></form>"
      end
    else
      "<form method=\"get\" action=\"#{edit_setup_price_path(price_id)}\" class=\"button-to\"><div><input type=\"hidden\" name=\"season_id\" value=\"#{season_id}\"/><input type=\"submit\" value=\"none\" /></div></form>"
    end
  end
end
