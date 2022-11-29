module Report::AvailablesHelper
  Winter = 1
  Summer = 2
  @ce = Date.new
  @cs = Date.new

  def header
    logger.debug 'header'

    av_init
    ret_str = get_header_months
    ret_str << get_header_days
  end

  def hdr_init
    if @option.use_park_closed?
      @cs = @option.closed_start.change(:year => @startDate.year)
      @ce = @option.closed_end.change(:year => @startDate.year)
      logger.debug "hdr_init: start date is #{@startDate} and @ce is #{@ce}"
      if @startDate >= @ce && @closedType == Winter
	@ce = @ce.change(:year => currentDate.year + 1)
	logger.debug "hdr_init: winter: start date is #{@startDate} and @ce is #{@ce}"
      end
    end
  end

  def get_header_months
    hdr_init
    ret_str = '<tr><th class="locked" style="border:1px solid black;background:Lavender">'
    if @option.max_spacename > 5
      spacer = ((@option.max_spacename - 4)/1.5).to_i
      ret_str << '&nbsp;' * spacer
      ret_str << I18n.t('reservation.Space')
      ret_str << '&nbsp;' * spacer
    else 
      ret_str << 'Space'
    end
    ret_str << '</th>'
    # print out the months
    date = @startDate 
    first_closed = true
    day = Date.new
    logger.debug "get_header_months: enddate is #{@endDate}"
    while date < @endDate 
      # if @option.use_park_closed? && date > @cs && date > @ce
      # if @option.use_park_closed? && date > @cs
        # we are past the original dates...up start and end by a year
        # @cs = @cs.change(:year => @cs.year + 1)
        # @ce = @ce.change(:year => @ce.year + 1)
      # end
      hdr_count,day = hdr_day_count(date)
      # print out as month
      logger.debug "get_header_months: date is #{date}, next day is #{day} count is #{hdr_count}"
      if hdr_count > 0
	if hdr_count < 3
	  ret_str << "<th class=\"av_date\" colspan=\"#{hdr_count}\" style=\"text-align:center;border:1px solid black;background:Lavender\"></th>"
	elsif hdr_count < 5
	  ret_str << "<th class=\"av_date\" colspan=\"#{hdr_count}\" style=\"text-align:center;border:1px solid black;background:Lavender\">#{I18n.l(date,:format => :month)}</th>"
	else 
	  ret_str << "<th class=\"av_date\" colspan=\"#{hdr_count}\" style=\"text-align:center;border:1px solid black;background:Lavender\">#{I18n.l(date,:format => :month_year)}</th>"
	end
	logger.debug "setting date to #{day}"
	date = day
      else
	logger.debug "setting date to #{@ce + 1}"
        date = @ce + 1
      end
      if @option.use_park_closed? && (@ce + 1 == date)
	ret_str << '<th class="av_date" style="border:1px solid black;background-color:DarkGrey"></th>'
	@ce = @ce.change(:year => @ce.year + 1)
	@cs = @cs.change(:year => @cs.year + 1)
      end
    end
    ret_str << "</tr>\n"
  end

  def hdr_day_count(this_date)
    if @option.use_park_closed?
      logger.debug "hdr_day_count #{this_date}, @cs = #{@cs}, @ce = #{@ce}"
      if this_date == @cs
        logger.debug "hdr_day_count: date #{this_date} == #{@cs}"
	count = 0
	day = @ce + 1
      elsif @cs.month == this_date.month && @cs.year == this_date.year
        logger.debug "hdr_day_count: month #{@cs.month} == #{this_date.month}"
        if @ce.month == @cs.month
	  # ?count = this_date.end_of_month - this_date - @closedDays + 1
	  count = this_date.end_of_month - this_date
	  day = this_date.end_of_month + 1
	else
	  count = @cs - this_date
	  day = @ce + 1
	end
      else
        logger.debug "the rest"
	count = this_date.end_of_month - this_date + 1
	day = this_date.end_of_month + 1
      end
    else
      # never closed
      count = this_date.end_of_month - this_date + 1
      day = this_date.end_of_month + 1
    end
    return count,day
  end

  def get_header_days
    hdr_init
    # print out the days
    date = @startDate 
    first_closed = true
    ret_str = '<tr><th class="locked" style="border:1px solid black;background:Lavender"></th>'
    # logger.debug "get_header_days enddate is #{@endDate}"
    while date < @endDate 
      if @option.use_park_closed?
	count,day = hdr_day_count(date)
	if count == 0
	  ret_str << '<th class="av_date" style="border:1px solid black;background:DarkGrey"></th>'
	  @ce = @ce.change(:year => @ce.year + 1)
	  @cs = @cs.change(:year => @cs.year + 1)
	  date = day
	  next
	end
      end
      if date == currentDate
	ret_str << '<th class="av_date"  style="border:1px solid black;background:LightGreen">' + date.strftime("%d") + '</th>'
      elsif date.wday == 0 || date.wday == 6
	ret_str << '<th class="av_date"  style="border:1px solid black;background:lightGrey">' + date.strftime("%d") + '</th>'
      else
	ret_str << '<th class="av_date"  style="border:1px solid black;background:Lavender">' + date.strftime("%d") + '</th>'
      end   
      date = date.succ 
    end
    ret_str << "</tr>\n"
  end

  def available(res_hash)
    #############################################
    # res_hash is a hash of arrays of reservations
    # with the key being the space_id.  Each
    # array of reservations is sorted by startdate
    # key is space names content array of reservations
    #############################################
    debug 'available'
    ret_str = ''
    av_init
    # some copied some new
    Space.active(:order => 'position').each do |space|
      debug "space #{space.name}"
      date = @startDate # date starts over for each space
      ret_str << '<tr>'
      # start with the space name
      if space.unavailable?
	ret_str << '<td class="av_space"  style="border:1px solid black;background:Crimson">' +  space.name + '</td>' 
      else
	ret_str << '<td class="av_space"  style="border:1px solid black;background:Lavender">' +  space.name + '</td>'
      end
      if @option.use_park_closed?
	@cs = @closedStart
	@ce = @closedEnd
      end
      if res_hash.has_key? space.id
	# process this space
	res_hash[space.id].each do |res|
	  # process each reservation in the array
	  # all of the reservations in the array should be displayed 
	  # except for those in the closed dates (when applicable)
	  debug "handling reservation #{res.id} start #{res.startdate} end #{res.enddate}"
	  next if res.enddate <= @startDate
	  next if @option.use_park_closed? && res.startdate > @cs && res.enddate <= @ce # just like it wasn't there
	  debug "handle_cells 1 space #{space.id} reservation #{res.id} start #{res.startdate} end #{res.enddate}"
	  ret_str << handle_cells(date, res.startdate)
	  cnt = day_count(res)
	  name = trunc_name(cnt, res)
	  ret_str << "<td colspan=\"#{cnt}\" align=\"center\" "
	  if res.checked_in
	    ret_str << 'style="border:1px solid black;background-color:LimeGreen">' # occupied
	  else
	    if currentDate > res.startdate
	      ret_str << 'style="border:1px solid black;background-color:Yellow">' # overdue
	    else
	      ret_str << 'style="border:1px solid black;background-color:LightSteelBlue">' # reserved
	    end
	  end
	  if res.camper
	    title = res.camper.full_name + ', '
	    title << I18n.l(res.startdate, :format => :short) + I18n.t('reservation.To') + I18n.l(res.enddate, :format => :short)
	    ret_str << "<a href=\"/reservation/show?reservation_id=#{res.id}\" title=\"#{title}\">#{name}</a>"
	  else
	    ret_str << name
	  end
	  date = res.enddate
	end # processed a reservation
	debug "handle_cells finish up from #{date} to #{@endDate} after handling all reservations"
	ret_str << handle_cells(date, @endDate) # finish up the line
      else
	debug "no reservations for space #{space.name}"
	# put out an empty set of dates
	debug "handle_cells from #{@startDate} to #{@endDate}, no reservations on space #{space.id}"
	ret_str << handle_cells(@startDate, @endDate)
      end
      ret_str << "</tr>\n" # processed a space
    end
    return ret_str
  end

  def trunc_name(cnt, res)
    name_cnt = (cnt * 2).to_i
    if res.camper
      if res.camper.full_name.size > name_cnt
	if res.camper.last_name.size > name_cnt
	  res.camper.last_name[0,name_cnt]
	else
	  res.camper.last_name
	end
      else
	res.camper.full_name
      end
    else
      'pending'[0,name_cnt]
    end
  end

  def handle_cells(sd, ed)
    # handle the cells in a reservation
    # logger.debug "handle_cells: sd=#{sd}, ed=#{ed}"
    ret_str = ''
    if ed > @endDate
      logger.debug "handle_cells: end date adjusted from #{ed} to #{@endDate}"
      ed = @endDate
    end
    if sd >= ed
      logger.debug "handle_cells: return because start date #{sd} >= end date #{ed}"
      return ret_str
    end
    date = sd
    while date < ed
      logger.debug "handle_cells: #{date.to_s}"
      if @option.use_park_closed?
	@cs = @cs.change(:year => @cs.year + 1) if date > @cs
	@ce = @ce.change(:year => @ce.year + 1) if date > @ce
	logger.debug 'handle_cells: using closed dates'
	if date == currentDate
	  logger.debug 'handle_cells: currentDate'
	  ret_str << '<td style="border:1px solid black;background-color:LightGreen"></td>'
	  date += 1
	elsif date < @cs && ed < @cs
	  # case 1 between closures
	  logger.debug 'handle_cells: case 1'
	  if date > currentDate || ed < currentDate
	    ret_str << output_empty(date, (ed - date).to_i)
	    date = ed
	  else
	    ret_str << output_empty(date, (currentDate - date).to_i)
	    date = currentDate
	  end
	elsif date < @cs && ed >= @ce
	  # case 5 spanning closure
	  logger.debug 'handle_cells: case 5 output grey'
	  if date > currentDate || ed < currentDate
	    ret_str << output_empty(date, (@cs - date).to_i)
	    ret_str << '<td style="border:1px solid black;background-color:DarkGrey"></td>'
	    date = @ce + 1
	  else
	    ret_str << output_empty(date, (currentDate - date).to_i)
	    date = currentDate
	  end
	elsif date < @cs && ed >= @cs
	  # case 3 start before, end in closure
	  logger.debug 'handle_cells: case 3 output grey'
	  if date > currentDate || ed < currentDate || (currentDate > @cs && currentDate < @ce)
	    ret_str << output_empty(date, (@cs - date).to_i)
	    # ret_str << '<td style="border:1px solid black;background-color:DarkGrey"></td>'
	    date = @ce + 1
	  else
	    ret_str << output_empty(date, (currentDate - date).to_i)
	    date = currentDate
	  end
	elsif date >= @ce 
	  # case 2 between closures
	  logger.debug 'handle_cells: case 2'
	  cs_ = @cs.change(:year => @cs.year + 1)
	  logger.debug "handle_cells: changed @cs to #{@cs}"
	  if currentDate > date && currentDate <= ed  && currentDate < cs_
	    out_date = currentDate > cs_ ? cs_ - 1 : currentDate
	    ret_str << output_empty(date, (out_date - date).to_i)
	    date = out_date
	  else
	    out_date = ed > cs_ ? cs_ - 1 : ed
	    ret_str << output_empty(date, (out_date - date).to_i)
	    date = out_date
	  end
	elsif date > @cs && ed >= @ce
	  # case 4 start in closure
	  logger.debug 'handle_cells: case 4 output grey'
	  if date > currentDate || ed < currentDate
	    ret_str << '<td style="border:1px solid black;background-color:DarkGrey"></td>'
	    date = @ce + 1
	  else
	    ret_str << output_empty(date, (currentDate - date).to_i)
	    date = currentDate
	  end
	elsif date >= @cs && date < @ce
	  # case 6 within closure
	  logger.debug 'handle_cells: case 6 output grey'
	  ret_str << '<td style="border:1px solid black;background-color:DarkGrey"></td>'
	  date = @ce + 1
	else
	  # we should never get here
	  logger.debug "handle_cells: @cs is #{@cs}, @ce = #{@ce}"
	  raise 'error' 
	end
        logger.debug "handle_cells: using closed, next date is #{date}"
      else # no closed
	if date > currentDate
	  logger.debug "handle_cells: after currentDate, output_empty(#{date}, #{(ed - date).to_i})"
	  ret_str << output_empty(date, (ed - date).to_i)
	  date = ed
	elsif ed < currentDate
	  logger.debug "handle_cells: before currentDate, output_empty(#{date}, #{(ed - date).to_i})"
	  ret_str << output_empty(date, (ed -date).to_i)
	  date = ed
	elsif date == currentDate # current date
	  logger.debug 'handle_cells: outside of closed: date == currentDate'
	  ret_str << '<td style="border:1px solid black;background-color:LightGreen"></td>'
	  date = currentDate + 1
	else # date < currentDate && ed >= currentDate # spans current
	  logger.debug "handle_cells: starts before and spans currentDate, output_empty(#{date}, #{(currentDate - date).to_i})"
	  ret_str << output_empty(date, (currentDate - date).to_i)
	  date = currentDate
	end
      end
    end
    return ret_str
  end
  def xhandle_cells(sd, ed)
    logger.debug "handle_cells: sd=#{sd}, ed=#{ed}"
    ret_str = ''
    if ed > @endDate
      logger.debug "handle_cells: end date adjusted from #{ed} to #{@endDate}"
      ed = @endDate
    end
    if sd >= ed
      logger.debug "handle_cells: return because start date #{sd} >= end date #{ed}"
      return ret_str
    end

    date = sd
    while date < ed
      logger.debug "handle_cells: #{date.to_s}"
      if @option.use_park_closed?
	if date > @ce
	  @cs = @cs.change(:year => @cs.year + 1)
	  @ce = @ce.change(:year => @ce.year + 1)
	  logger.debug "handle_cells: changed @cs to #{@cs} and changed @ce to #{@ce}"
	end
	logger.debug 'handle_cells: using closed dates'

	if date == currentDate
	  logger.debug 'handle_cells: currentDate'
	  ret_str << '<td style="border:1px solid black;background-color:LightGreen"></td>'
	  date += 1
	elsif date < @cs && ed < @cs
	  # case 1 between closures
	  logger.debug 'handle_cells: case 1'
	  if date > currentDate || ed < currentDate
	    ret_str << output_empty(date, (ed - date).to_i)
	    date = ed
	  else
	    ret_str << output_empty(date, (currentDate - date).to_i)
	    date = currentDate
	  end
	elsif date < @cs && ed >= @ce
	  # case 5 spanning closure
	  logger.debug 'handle_cells: case 5 output grey'
	  if date > currentDate || ed < currentDate
	    ret_str << output_empty(date, (@cs - date).to_i)
	    ret_str << '<td style="border:1px solid black;background-color:DarkGrey"></td>'
	    date = @ce + 1
	  else
	    ret_str << output_empty(date, (currentDate - date).to_i)
	    date = currentDate
	  end
	elsif date < @cs && ed >= @cs
	  # case 3 start before, end in closure
	  logger.debug 'handle_cells: case 3 output grey'
	  if date > currentDate || ed < currentDate || (currentDate > @cs && currentDate < @ce)
	    ret_str << output_empty(date, (@cs - date).to_i)
	    # ret_str << '<td style="border:1px solid black;background-color:DarkGrey"></td>'
	    date = @ce + 1
	  else
	    ret_str << output_empty(date, (currentDate - date).to_i)
	    date = currentDate
	  end
	elsif date >= @ce 
	  # case 2 between closures
	  logger.debug 'handle_cells: case 2'
	  cs_ = @cs.change(:year => @cs.year + 1)
	  logger.debug "handle_cells: changed @cs to #{@cs}"
	  if currentDate > date && currentDate <= ed  && currentDate < cs_
	    out_date = currentDate > cs_ ? cs_ - 1 : currentDate
	    ret_str << output_empty(date, (out_date - date).to_i)
	    date = out_date
	  else
	    out_date = ed > cs_ ? cs_ - 1 : ed
	    ret_str << output_empty(date, (out_date - date).to_i)
	    date = out_date
	  end
	elsif date > @cs && ed >= @ce
	  # case 4 start in closure
	  logger.debug 'handle_cells: case 4 output grey'
	  if date > currentDate || ed < currentDate
	    ret_str << '<td style="border:1px solid black;background-color:DarkGrey"></td>'
	    date = @ce + 1
	  else
	    ret_str << output_empty(date, (currentDate - date).to_i)
	    date = currentDate
	  end
	elsif date >= @cs && date < @ce
	  # case 6 within closure
	  logger.debug 'handle_cells: case 6 output grey'
	  ret_str << '<td style="border:1px solid black;background-color:DarkGrey"></td>'
	  date = @ce + 1
	else
	  # we should never get here
	  logger.debug "handle_cells: @cs is #{@cs}, @ce = #{@ce}"
	  raise 'error' 
	end
        logger.debug "handle_cells: using closed, next date is #{date}"
      else # no closed
	if date > currentDate
	  logger.debug "handle_cells: after currentDate, output_empty(#{date}, #{(ed - date).to_i})"
	  ret_str << output_empty(date, (ed - date).to_i)
	  date = ed
	elsif ed < currentDate
	  logger.debug "handle_cells: before currentDate, output_empty(#{date}, #{(ed - date).to_i})"
	  ret_str << output_empty(date, (ed -date).to_i)
	  date = ed
	elsif date == currentDate # current date
	  logger.debug 'handle_cells: outside of closed: date == currentDate'
	  ret_str << '<td style="border:1px solid black;background-color:LightGreen"></td>'
	  date = currentDate + 1
	else # date < currentDate && ed >= currentDate # spans current
	  logger.debug "handle_cells: starts before and spans currentDate, output_empty(#{date}, #{(currentDate - date).to_i})"
	  ret_str << output_empty(date, (currentDate - date).to_i)
	  date = currentDate
	end
      end
    end
    return ret_str
  end

  def output_empty(in_sd, count)
    # sd = (in_sd.class == 'Date' ? in_sd : Date.parse(in_sd))
    logger.debug "output_empty: sd = #{in_sd} count = #{count}"
    sd = in_sd
    ret_str = ''
    while count > 0
      # logger.debug "output_empty:sd is #{sd}, day = #{sd.wday} and count is #{count}"
      case sd.wday
      when 6 # saturday
	# logger.debug 'output_empty: saturday'
	if count > 6
	  ret_str << '<td style="border:1px solid black;background-color:lightGrey"></td><td style="border:1px solid black;background-color:lightGrey"></td><td></td><td></td><td></td><td></td><td></td>'
	  count -= 7
	  sd += 7.days
	else
	  ret_str << '<td style="border:1px solid black;background-color:lightGrey"></td>'
	  count -= 1
	  sd += 1.days
	end
      when 0 # sunday
	# logger.debug 'output_empty: sunday'
	cnt = count < 6 ? count : 6
	ret_str << '<td style="border:1px solid black;background-color:lightGrey"></td>' + '<td></td>' * (cnt - 1)
	count -= cnt
	sd += cnt.days
      when 1 # monday
	# logger.debug 'output_empty: monday'
	cnt = count < 5 ? count : 5
	ret_str << '<td></td>' * cnt
	count -= cnt
	sd += cnt.days
      when 2 # tuesday
	# logger.debug 'output_empty: tuesday'
	cnt = count < 4 ? count : 4
	ret_str << '<td></td>' * cnt
	count -= cnt
	sd += cnt.days
      when 3 # wednesday
	# logger.debug 'output_empty: wednesday'
	cnt = count < 3 ? count : 3
	ret_str << '<td></td>' * cnt
	count -= cnt
	sd += cnt.days
      when 4 # thursday
	# logger.debug 'output_empty: thursday'
	cnt = count < 2 ? count : 2
	ret_str << '<td></td>' * cnt
	count -= cnt
	sd += cnt.days
      when 5 # friday
	# logger.debug 'output_empty: friday'
	ret_str << '<td></td>' * 1
	count -= 1
	sd += 1.days
      else
	# error "output_empty: sd is #{sd} and count is #{count}"
      end
    end
    return ret_str
  end

  def day_count(res)
    if res.startdate > @endDate
      logger.debug "day_count: reservation starts late #{res.startdate}"
      return 0
    elsif @startDate > res.startdate 
      startdate = @startDate 
      logger.debug 'day_count: 1'
    else
      startdate = res.startdate
      logger.debug 'day_count: 2'
    end
    if res.enddate < @endDate 
      enddate = res.enddate 
      logger.debug 'day_count: 3'
    else
      enddate = @endDate
      logger.debug 'day_count: 4'
    end
    if @option.use_park_closed?
      logger.debug "day_count: use_park_closed.. startdate = #{res.startdate} enddate = #{res.enddate}"
      if enddate < @closedStart || startdate > @closedEnd
	# We are open just a normal count - case 1 & 2
	logger.debug "day_count: #{enddate} < #{@closedStart} or #{startdate} > #{@closedEnd}"
	logger.debug 'day_count: 1 - normal count'
        cnt = enddate - startdate
      elsif startdate < @closedStart && enddate > @closedEnd
	logger.debug "day_count: #{startdate} < #{@closedStart} && #{enddate} > #{@closedEnd}"
        logger.debug 'day_count: 2 - spanning'
	cnt = enddate - startdate - @closedDays
      elsif startdate >= @closedStart && enddate < @closedEnd
	logger.debug 'day_count: 3 - start and end in closed'
        cnt = 0
      elsif startdate < @closedStart && enddate >= @closedStart
	logger.debug "day_count: #{startdate} < #{@closedStart} && #{enddate} > #{@closedStart}"
	logger.debug 'day_count: 4 - start before closed end in closed'
        cnt = @closedStart - startdate
      elsif startdate >= @closedStart && startdate < @closedEnd && enddate > @closedEnd
	logger.debug 'day_count: 5 - start in closed and end after closed'
        cnt = enddate - @closedEnd 
      else
	logger.debug "day_count: startdate #{startdate} enddate #{enddate}"
        logger.debug 'day_count: 6 - how did we get here?'
	cnt = 0
      end
    else
      cnt = enddate - startdate
      cnt = cnt > 1 ? cnt : 1
    end
    if res.camper
      name = res.camper.full_name
    else
      name = 'pending'
    end
    logger.debug "day_count: count for #{res.id}, #{name} #{res.startdate} to #{res.enddate} is #{cnt}"
    logger.debug "day_count: startdate is #{startdate}, enddate is #{enddate}"
    return cnt
  end

  def av_init
    logger.debug 'av_init'
    @closedDays = 0
    @startDate = currentDate - @option.lookback
    days = @option.sa_columns + @option.lookback
    if @option.use_park_closed?
      @closedType = Summer
      @closedStart = @option.closed_start.change(:year => currentDate.year) 
      @closedEnd = @option.closed_end.change(:year => currentDate.year)
      if @closedStart > @closedEnd
        logger.debug "av_init: closed start is #{@closedStart} and closed end is #{@closedEnd} giving type Winter"
        @closedType = Winter
	if @startDate < @closedEnd
	  @startDate = @closedEnd
	end
        @closedEnd = @closedEnd.change(:year => currentDate.year + 1)
      else
        logger.debug "av_init: closed start is #{@closedStart} and closed end is #{@closedEnd} giving type Summer"
      end
      date = @startDate
      cs = @closedStart
      ce = @closedEnd
      day_cnt = 0
      while day_cnt < days
        if date < cs
	  day_cnt += 1
	elsif date == ce
	  ce = ce.change(:year => ce.year + 1)
	  cs = cs.change(:year => cs.year + 1)
	else
	  @closedDays += 1
	end
	date = date.succ
      end
      @endDate = date
      logger.debug "av_init: closed from #{@closedStart} to #{@closedEnd} for #{@closedDays} days type #{@closedType}"
    else
      @endDate = @startDate + days
    end
    logger.debug "av_init: starting at #{@startDate} and ending at #{@endDate}"
  end

end
