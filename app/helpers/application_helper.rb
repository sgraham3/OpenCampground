# Methods added to this helper will be available to all templates in the application.
require 'charges.rb'
module ApplicationHelper
  include MyLib
  
  def pmt_id(pmt)
    pmt.created_at.to_i.to_s
  end

  def spancount
    cnt = 2
    cnt += 1 if @option.use_rig_type?
    cnt += 1 if @option.use_license?
    cnt += 1 if @option.use_slides?
    cnt += 1 if @option.use_length?
    cnt += 2 if @option.list_payments?
    cnt.to_s
  end

  def safeCamper(camper_id)
    Camper.find(camper_id).full_name
  rescue StandardError
    debug 'no camper'
    'camper not found'
  end
  
  def safeDate(dt)
    if dt
      I18n.l dt
    else
      'none'
    end
  end

  def safePrint(item=0)
    if item == 0
      '0'
    elsif item == nil
      'nil'
    else
      item.to_s
    end
  rescue
    'nil'
  end

  def safeSpace(sp_id)
    Space.find(sp_id).name
  rescue
    debug 'no space'
    'space not found'
  end

  def measured_extras?
    Extra.count(:conditions => ["extra_type = ?", Extra::MEASURED]) > 0 
  end

  def cds_format(date_format = 'default')
    format  = I18n.t(:"date.formats.#{date_format}" )
    debug 'initial format is ' + format
    # format = resolve(locale, object, format, options)
    # format = format.to_s.gsub(/%[aAbB]/) do |match|
      # case match
      # when '%a' then I18n.t(:"date.abbr_day_names",                  :locale => locale, :format => format)[object.wday]
      # when '%A' then I18n.t(:"date.day_names",                       :locale => locale, :format => format)[object.wday]
      # when '%b' then I18n.t(:"date.abbr_month_names",                :locale => locale, :format => format)[object.mon]
      # when '%B' then I18n.t(:"date.month_names",                     :locale => locale, :format => format)[object.mon]
      # end
    # end

    debug 'edited format is ' + format
    case format
    when "%B %d, %Y"
      result = 'natural'
    when "%b %d, %Y"
      result = 'short'
    when "%Y.%m.%d"
      result = 'euro_24hr_ymd'
    when  "%Y-%m-%d"
      result = 'iso_date'
    when "%d.%m.%Y"
      result = 'finnish'
    when "%d/%m/%Y"
      result = 'danish'
    when "%m/%d/%Y","%m-%d-%Y"
      result = 'american'
    when "%d %B %Y"
      result = 'euro_24hr'
    else
      result = 'iso_date'
    end
    debug 'returning ' + result
    return result
  end

  def close_reason(res)
    arc = Archive.find_by_reservation_id(res.id)
    return ' ' if arc == nil
    if arc.close_reason.size > 0
      result = arc.close_reason.partition(' ')
      return result[0]
    else
      return ' '
    end
  end

  def current_Date
    currentDate
  end

  def current_Time
    currentTime
  end

  def authorized? ( item )
    # logger.debug "authorized? input is #{item}"
    if item == 'admin'
      if @option.use_login 
	if @user_login.admin
	  return true
	else
	  return false
	end
      else
	return true
      end
    end

    if @option.use_login 
      # logger.debug 'authorized? using login'
      if @user_login.admin
	# logger.debug 'authorized? admin user...return true'
        return true
      else
	# logger.debug "authorized? non admin returning #{item}"
	return item
      end
    else
      # logger.debug 'authorized? not using login...return true'
      return true
    end
  end

  def cents_to_dollars(cents)
    if cents > 0
      sprintf("%d.%02d", cents/100, cents.modulo(100))
    else
      "0.00"
    end
  end

  # put this in the body after a form to set the input focus to a specific control id
  # at end of rhtml file: <%= set_focus_to_id 'form_field_label' %>
  # Thanks to Dana Jones from Sterling Rose Design (sterlingrosedesign.com)
  def set_focus_to_id(id)
    javascript_tag("window.onload = $('#{id}').focus()")
  end

  def in_place_editor_field_prompted( object, attribute, tag_options = {}, in_place_editor_options = {})
    # a layer on in_place_editor to take care of the fact that some browsers
    # like chrome do not display fields which are blank so for them we will put up
    # an edit button on blank fields
    case @browser
    when :ffox
      in_place_editor_field(object, attribute, tag_options, in_place_editor_options)
    else
      instance_tag = ::ActionView::Helpers::InstanceTag.new(object, attribute, self)
      item = instance_tag.value(instance_tag.object)
      if item.blank?
	id = "edit_" + object.to_s + attribute.to_s
	in_place_editor_options.merge!(:external_control => id )
	"<input type=\"button\" id=\"#{id}\" value=\"edit\"\/>" + in_place_editor_field(object, attribute, tag_options, in_place_editor_options)
      else
	in_place_editor_field(object, attribute, tag_options, in_place_editor_options)
      end
    end
  end

  def charge_item(charge, use_discount, season_count)
  # logger.debug charge.inspect
  logger.debug 'discount is ' + (use_discount ? 'true' : 'false')
  logger.debug 'season count is ' + season_count.to_s
    case charge.charge_units
    when Charge::DAY
      str = "<td>" + I18n.t('reservation.Days') + "</td>"
      logger.debug 'days'
    when Charge::WEEK
      str = "<td>" + I18n.t('reservation.Weeks') + "</td>"
      logger.debug 'weeks'
    when Charge::MONTH
      str = "<td>" + I18n.t('reservation.Months') + "</td>"
      logger.debug 'months'
    when Charge::SEASON
      str = "<td>" + I18n.t('reservation.Season') + "</td>"
      logger.debug 'season'
    when Charge::STORAGE
      str = "<td>" + I18n.t('reservation.Storage') + "</td>"
      logger.debug 'storage'
    end
    str << "<td align='center'>" + DateFmt.format_date(charge.start_date,'long') + "</td>" 
    str << "<td align='center'>" + DateFmt.format_date(charge.end_date,'long') + "</td>" 
    str <<  "<td align='center'>" + charge.season.name + "</td>"  if season_count > 1
    str <<  "<td align='right'>" + sprintf("%6.2f", charge.period) + "</td>" 
    str << "<td align='right'>" + number_2_currency(charge.rate) + "</td>"
    if use_discount
      str << "<td align='right'>" + number_2_currency(charge.amount) + "</td>" if @option.inline_subtotal?
      str << "<td align='right'>" + number_2_currency(charge.discount) + "</td>" 
    end
    str << "<td align='right'>" + number_2_currency(charge.amount - charge.discount) + "</td>"
  end

  def charge_variable(v, use_discount, season_count)
    logger.debug "charge_variable: #{v.detail}, #{v.amount}"
    if v.amount != 0.0
      str = "<tr><td align='left' colspan='5'>#{v.detail}</td>"
      str << "<td></td>" unless @reservation.seasonal? || @season_cnt == 1 
      if use_discount
	str << "<td></td>" if @option.inline_subtotal?
	str << "<td></td>"
      end
      str << "<td align='right'> #{number_2_currency(v.amount)} </td></tr>"
    else
      ''
    end
  end

  def charge_extra(e, use_discount, season_count)
    str = ''
    # str << "<td>extra_charge id #{e.id}</td><td>extra id #{e.extra_id}</td><td>#{e.extra.extra_type}</td><td>#{e.extra.charge}</td><td>#{e.charge}</td></tr><tr>"
    case e.extra.extra_type
    when Extra::OCCASIONAL
      if e.charge != 0.0
	str << "<tr><td align='left'>#{e.extra.name}</td>"
	str << "<td></td> <td></td>"
	str << "<td></td>" unless @reservation.seasonal? || @season_cnt == 1 
	str << "<td align='center'> #{ e.number.to_s  }</td>"
	str << "<td align='right'> #{number_2_currency(e.extra.charge)} </td>"
	if use_discount
	  if @option.inline_subtotal?
	    str << "<td></td>"
	  end
	  str << "<td></td>"
	end
	str << "<td align='right'> #{number_2_currency(e.charge)} </td></tr>"
      end
    when Extra::DEPOSIT
      if e.charge != 0.0
	str << "<tr><td align='left'>#{e.extra.name}</td>"
	str << "<td></td> <td></td>"
	str << "<td></td>" unless @reservation.seasonal? || @season_cnt == 1 
	str << "<td></td>"
	str << "<td></td>"
	if use_discount
	  if @option.inline_subtotal?
	    str << "<td></td>"
	  end
	  str << "<td></td>"
	end
	str << "<td align='right'> #{number_2_currency(e.charge)} </td></tr>"
      end
    when Extra::MEASURED
      if e.charge > 0.0
	str << "<tr><td align='left'> #{e.extra.name} #{e.extra.unit_name} </td>"
	str << "<td>#{e.initial}:#{e.final}</td>"
	str << "<td>#{ DateFmt.format_date(e.created_on,'long')}</td>"
	str << "<td></td>" unless @reservation.seasonal? || @season_cnt == 1 
	str << "<td align='right'> #{e.final - e.initial} </td>"
	str << "<td align='right'> #{number_2_currency(e.measured_rate)} </td>"
	if use_discount
	  if @option.inline_subtotal?
	    str << "<td></td>"
	  end
	  str << "<td></td>"
	end
	str << "<td align='right'> #{number_2_currency(e.charge)} </td></tr>"
      end
    else
      unless (e.extra.extra_type == Extra::COUNTED) && (e.number == 0)
	if e.days > 0
	  str << "<tr><td align='left'>#{e.extra.name} days</td> <td></td> <td></td>"
	  str << "<td></td>" unless @reservation.seasonal? || @season_cnt == 1 
	  str << "<td align='center'> #{ (e.extra.extra_type == Extra::COUNTED) ?  (e.days * e.number).to_s : e.days.to_s } </td>"
	  str << "<td align='right'> #{number_2_currency(e.extra.daily)} </td>"
	  if use_discount
	    if @option.inline_subtotal?
	      str << "<td></td>"
	    end
	    str << "<td></td>"
	  end
	  str << "<td align='right'> #{number_2_currency(e.daily_charges)} </td></tr>"
	end 
	if e.weeks > 0
	  str << "<tr><td align='left'>#{e.extra.name} weeks</td> <td></td> <td></td>"
	  str << "<td></td>" unless @reservation.seasonal? || @season_cnt == 1 
	  str << "<td align='center'> #{ (e.extra.extra_type == Extra::COUNTED) ?  (e.weeks * e.number).to_s : e.weeks.to_s } </td>"
	  str << "<td align='right'> #{number_2_currency(e.extra.weekly)} </td>"
	  if use_discount
	    if @option.inline_subtotal?
	      str << "<td></td>"
	    end
	    str << "<td></td>"
	  end
	  str << "<td align='right'> #{number_2_currency(e.weekly_charges)} </td></tr>"
	end
	if e.months > 0 
	  str << "<tr><td align='left'>#{e.extra.name} months</td> <td></td> <td></td>"
	  str << "<td></td>" unless @reservation.seasonal? || @season_cnt == 1 
	  str << "<td align='center'> #{ (e.extra.extra_type == Extra::COUNTED) ?  (e.months * e.number).to_s : e.months.to_s } </td>"
	  str << "<td align='right'> #{number_2_currency(e.extra.monthly)} </td>"
	  if use_discount
	    if @option.inline_subtotal?
	      str << "<td></td>"
	    end
	    str << "<td></td>"
	  end
	  str << "<td align='right'> #{number_2_currency(e.monthly_charges)} </td></tr>"
	end
      end
    end 
    str
  end

  def spacing_for_charges
    if @reservation.seasonal? || (@season_cnt == 1)
      if @discount == true
	if @option.inline_subtotal?
	  span = 6
	else
	  span = 5
	end
      else
	span = 4
      end
    else
      if @discount == true
	if @option.inline_subtotal?
	  span = 7
	else
	  span = 6
	end
      else
	span = 5
      end
    end
    "<td colspan=\"#{span}\"/>"
  end

  def extensible?(res)
    return true if controller.action_name == 'new'
    Reservation.all(:conditions => ["archived = ? AND id != ? AND space_id = ? AND startdate = ?",  false, res.id, res.space_id, res.enddate]).empty?
  rescue
    error
    false
  end

  def extend_stay(res)
    ret_str = ''
    return if res.seasonal?
    if Reservation.all(:conditions => ["archived = ? AND id != ? AND space_id = ? AND startdate <= ?",  false, res.id, res.space_id, res.enddate]).empty?
      ret_str << "<td>" + link_to(I18n.t('reservation.Extend'), {:action => 'extend_stay', :reservation_id => res.id}, :confirm => I18n.t('reservation.ConfirmExtend', :name => res.camper.full_name), :method => "post") + "</td>"
    end
    if ((res.enddate - res.startdate).to_i > 20) && Reservation.all(:conditions => ["archived = ? AND id != ? AND space_id = ? AND startdate < ?",  false, res.id, res.space_id, res.enddate + 1.month]).empty?
      ret_str << "<td>" + link_to(I18n.t('reservation.ExtendMonth'), {:action => 'extend_stay', :reservation_id => res.id, :enddate => res.enddate + 1.month}, :confirm => I18n.t('reservation.ConfirmExtendMonth', :name => res.camper.full_name, :enddate => res.enddate + 1.month), :method => "post") + "</td>"
    end
    return ret_str unless ret_str.empty?
  rescue
    error
    # do nothing
  end

  def list_item( controller, action )
    if current_page?(:controller => controller, :action => action) 
      "<li id=\"selected\">"
    else
      "<li>"
    end
  end

  def spaces_display
    if @remote
      if @option.use_remote_map
	'<table cellpadding="5" cellspacing="0" >'
      else
	'<table cellpadding="5" cellspacing="0" style="margin-left: 10em;" >'
      end
    else 
      if @option.use_map
	'<table cellpadding="5" cellspacing="0" style="width: 100%;" >'
      else
	if @option.tabs 
	  '<table cellpadding="5" cellspacing="0" style="margin-left: 10em;" >'
	else
	  '<table cellpadding="5" cellspacing="0" style="margin-left: 5em;" >'
	end
      end
    end
  end

  # use calendar_date_select to display dates
  def cds_start( obj, atrib, update, remote=false)
    offset = 0.day
    cds( obj, atrib, update, offset, remote)
  end

  def cds_end( obj, atrib, update, remote=false)
    offset = 1.day
    cds( obj, atrib, update, offset, remote)
  end

  def unavailable(offset, remote)
    logger.debug "unavailable" 
    options = Option.first
    unavail = []
    if remote
      logger.debug "unavailable: remote" 
      # blackouts only apply to remote reservations
      Blackout.active.each do |b|
        # remote reservations are not in the past
	next if b.enddate < currentDate
	logger.debug "unavailable: blackout #{b.name}"
	ed = (b.enddate+offset).strftime("%d %b, %Y")
	sd = (b.startdate+offset).strftime("%d %b, %Y")
	unavail << "\nelse if ((date.stripTime() >= (new Date(\'#{sd}\')).stripTime()) && (date.stripTime() <= (new Date(\'#{ed}\')).stripTime())) return false;"
      end
    end
    if !session[:select_change] && defined?(@reservation) && @reservation.space_id > 0 &&
		( controller.action_name == 'change_dates' ||
		  controller.action_name == 'calendar_end_update' ||
		  controller.action_name == 'calendar_update')
      # get reservations that will limit changes
      # need to exclude present res...
      res = Reservation.all :conditions => ["space_id = ? and id != ? and enddate > ? and startdate < ? and archived = ?",
			                    @reservation.space_id, @reservation.id, Date.current.prev_year, Date.current + 3.years, false], :order => 'startdate'
      res.each do |r|
	logger.debug "unavailable: reservations #{r.id} with start #{r.startdate} and end #{r.enddate}"
	ed = (r.enddate+offset).strftime("%d %b, %Y")
	sd = (r.startdate+offset).strftime("%d %b, %Y")
	unavail << "\nelse if ((date.stripTime() >= (new Date(\'#{sd}\')).stripTime()) && (date.stripTime() < (new Date(\'#{ed}\')).stripTime())) return false;"
      end
    end
    if options.use_closed
      logger.debug "unavailable: closed"
      # put in closed dates
      # iterate from last year to year + 3 and get closed dates
      if remote
	year = Date.current.year
      else
	year = Date.current.year - 1
      end
      end_year = Date.current.year + 2
      while year <= end_year do
	if options.closed_start > options.closed_end
	  # closure spans new year
	  sd = (options.closed_start.change(:year => year - 1)+offset).strftime("%d %b, %Y")
	  ed = (options.closed_end.change(:year => year)+offset).strftime("%d %b, %Y")
	  unavail << "\nelse if ((date.stripTime() >= (new Date(\'#{sd}\')).stripTime()) && (date.stripTime() <= (new Date(\'#{ed}\')).stripTime())) return false;"
	else
	  # close start and end in the same year
	  sd = (options.closed_start.change(:year => year)+offset).strftime("%d %b, %Y")
	  ed = (options.closed_end.change(:year => year)+offset).strftime("%d %b, %Y")
	  unavail << "\nelse if ((date.stripTime() >= (new Date(\'#{sd}\')).stripTime()) && (date.stripTime() <= (new Date(\'#{ed}\')).stripTime())) return false;"
	end
        year += 1
      end
    end
    logger.debug "unavailable:unavail is #{unavail.inspect}"
    if remote
      str = "\nif (date.stripTime() <= (new Date(\'#{Date.current}\')).stripTime())return false;"
    else
      dt = Date.current - 1.year
      str = "\nif ((date.stripTime() < (new Date(\'#{dt}\')).stripTime())) return false;"
    end
    unavail.each { |u| str << u}
    str << "else return true;\n"

    # logger.debug "unavailable:str is #{str.inspect}"
    return str
  end

  def cds( obj, atrib, update, offset, remote )
    logger.debug "cds"
    if remote
      logger.debug "cds: in remote"
      str = "<noscript> #{date_select obj, atrib, :start_year => Date.current.year}  </noscript>\n"
      str << calendar_date_select(obj, atrib,
                                  :embedded => :true, 
		                  :valid_date_check => "#{unavailable(offset,true)}",
		                  :year_range => Date.current.year..3.years.from_now.year,
		                  :onchange => "new Ajax.Request(\'/remote/#{update}?date=\' + $F(this), {asynchronous:true, evalScripts:true});",
		                  :size => 15)
    else
      logger.debug "cds: in local"
      str = "<noscript> #{date_select obj, atrib, :start_year => 1.years.ago.year}  </noscript>\n"
      str << calendar_date_select(obj, atrib,
		                  :embedded => :true, 
		                  :valid_date_check => unavailable(offset,false ),
		                  :year_range => 1.years.ago.year..3.years.from_now.year,
		                  :onchange => "new Ajax.Request(\'/reservation/#{update}?date=\' + $F(this), {asynchronous:true, evalScripts:true});",
		                  :size => 15)
    end
  end

  def departures(startdate, enddate)
    if startdate == enddate
      reservations = Reservation.all( :conditions => ["confirm = ? and ENDDATE >= ? AND ENDDATE <= ? and archived = ?",
						       true, startdate, enddate, false],
				       :include => "camper",
				       :order => "campers.last_name asc" )
    else
      reservations = Reservation.all( :conditions => ["confirm = ? and ENDDATE >= ? AND ENDDATE <= ? and archived = ?",
						       true, startdate, enddate, false],
				       :include => "space",
				       :order => "enddate,spaces.position asc" )
    end
    return reservations
  end

  def arrivals(startdate, enddate)
    if startdate == enddate
      reservations = Reservation.all( :conditions => ["confirm = ? and STARTDATE >= ? AND STARTDATE <= ? and archived = ?",
						       true, startdate, enddate, false],
				       :include => "camper",
				       :order => "campers.last_name asc" )
    else
      reservations = Reservation.all( :conditions => ["confirm = ? and STARTDATE >= ? AND STARTDATE <= ? and archived = ?",
						       true, startdate, enddate, false],
				       :include => "space",
				       :order => "startdate,spaces.position asc" )
    end
    return reservations
  end

  def variable_charge_taxrates
    # @variable_charge and @taxes are available  
    # debug "variable_charge #{@variable_charge.id} currently has these taxrates #{@variable_charge.taxrate_ids.inspect}"
    ret_str = ''
    Taxrate.active.each do |t|
      if t.is_percent?
	debug "#{t.name} is percent"
	ret_str << t.name + ': '
	if @variable_charge.taxrates.exists?(t)
	  # taxrate t currently applies to the variable_charge
	  debug "taxrate #{t.id} currently applies to variable_charge #{@variable_charge.id}"
	  ret_str << "<input name=\"taxes[#{t.name}]\" type=\"hidden\" value=\"0\" /><input checked=\"checked\" id=\"#{t.name}\" name=\"taxes[#{t.name}]\" type=\"checkbox\" value=\"1\" \/>  "
	else
	  debug "taxrate #{t.id} currently does not apply to variable_charge #{@variable_charge.id}"
	  ret_str << "<input name=\"taxes[#{t.name}]\" type=\"hidden\" value=\"0\" /><input id=\"#{t.name}\" name=\"taxes[#{t.name}]\" type=\"checkbox\" value=\"1\" \/>  "
	end
      else
        debug "#{t.name} not percent"
      end
    end
    return ret_str
  end

private
  
  def closed(offset)
    if @option.use_park_closed?
      closedStart = (@option.closed_start+offset).change(:year => currentDate.year)
      closedEnd = (@option.closed_end+offset).change(:year => currentDate.year)
      if closedStart > closedEnd # closed in winter
	if currentDate > closedEnd
	  closedEnd = closedEnd.change(:year => (currentDate.year + 1))
	else
	  closedStart = closedStart.change(:year => (currentDate.year - 1))
        end 
      end
      ec = closedEnd.strftime("%d %b, %Y")
      sc = closedStart.strftime("%d %b, %Y")
      str = "if ((date.stripTime() >= (new Date(\'#{sc}\')).stripTime()) && (date.stripTime() <= (new Date(\'#{ec}\')).stripTime())) return false;"
      # logger.debug str
      2.times do
	closedEnd = closedEnd.change(:year => (closedEnd.year + 1))
	closedStart = closedStart.change(:year => (closedStart.year + 1))
	ec = closedEnd.strftime("%d %b, %Y")
	sc = closedStart.strftime("%d %b, %Y")
	str << "\nelse if ((date.stripTime() >= (new Date(\'#{sc}\')).stripTime()) && (date.stripTime() <= (new Date(\'#{ec}\')).stripTime())) return false;"
	# logger.debug str
      end
      str << "else return true;\n"
      # logger.debug str
    else
      str = "return true;\n"
      # logger.debug str
    end
    return str
  end
end
