class Report::ExtrasController < ApplicationController
  before_filter :login_from_cookie
  before_filter :check_login

  # GET /report_extras/new
  # GET /report_extras/new.xml
  def new
    @page_title = "Extras Report Definition"
    @reservation = Reservation.new
    @reservation.startdate = currentDate
    @reservation.enddate = currentDate
    @extras = Extra.active
    @extra = Extra.new
  end


  # POST /report_extras
  # POST /report_extras.xml
  def create
    # subtotal possibilities are:
    # None, Reservation, Week, Month
    # report possibilities are
    # Report, CSV
    if params[:csv]
      subtotal_on = session[:subtotal_on]
      startdate = session[:startdate]
      enddate = session[:enddate]
      debug "start #{startdate} end #{enddate} order #{session[:order]} cond #{session[:cond]} subtotal #{subtotal_on}\n"
      csv_string = ''
      @extra_charges_array = extra_charges_array(session[:startdate], session[:enddate], session[:order], session[:cond])
      Extra.all.each do |extra|
        next unless @extra_charges_array[extra.id]
	case extra.extra_type
        when Extra::MEASURED
	  debug 'Extra::MEASURED'
	  # save values for subtotals
	  res = @extra_charges_array[extra.id][0].reservation_id
	  week = @extra_charges_array[extra.id][0].updated_on.cweek
	  month = @extra_charges_array[extra.id][0].updated_on.month
	  subtotal = 0.0
	  total = 0.0
	  # generate the header string
	  csv_string << "#{extra.name}\nSpace,Reservation,Name,Date,Initial,Final,Used,Charge,Subtotal,Total\n"
	  @extra_charges_array[extra.id].each do |ec|
	    case subtotal_on
	    when 'Reservation'
              unless ec.reservation_id == res
                csv_string << "subtotal,,,,,,,,#{subtotal}\n"
                subtotal = 0.0
                res = ec.reservation_id
              end
            when 'Week'
              unless ec.updated_on.cweek == week
                csv_string << "subtotal,,,,,,,,#{subtotal}\n"
                subtotal = 0.0
                week = ec.updated_on.cweek
              end
            when 'Month'
              unless ec.updated_on.month == month
                csv_string << "subtotal,,,,,,,,#{subtotal}\n"
                subtotal = 0.0
                month = ec.updated_on.month
              end
            end
            subtotal += ec.charge
            total += ec.charge
            csv_string << "\"#{ec.reservation.space.name}\",#{ec.reservation_id},\"#{ec.reservation.camper.full_name}\",\"#{DateFmt.format_date(ec.updated_on)}\",#{ec.initial},#{ec.final},#{ec.final - ec.initial},#{ec.charge}\n"
          end
	  csv_string << "\"subtotal\",,,,,,,,#{subtotal}\n" if subtotal
          csv_string << "\"Total\",,,,,,,,,#{total}\n"  if total
	  csv_string << "\n"
        when Extra::STANDARD
	  debug 'Extra::STANDARD'
          # save values for subtotals
          res = @extra_charges_array[extra.id][0].reservation_id
          week = @extra_charges_array[extra.id][0].updated_on.cweek
          month = @extra_charges_array[extra.id][0].updated_on.month
          subtotal = 0.0
          # debug "subtotal 1 is #{@subtotal}"
          total = 0.0
          # generate the header string
          csv_string << "#{extra.name}\nSpace,Reservation,Name,Date,Charge,Subtotal,Total\n"
          @extra_charges_array[extra.id].each do |ec|
	    ec.charge = ec.daily_charges + ec.weekly_charges + ec.monthly_charges
            case subtotal_on
            when 'Reservation'
              unless ec.reservation_id == res
                csv_string << "subtotal,,,,,#{subtotal}\n"
                subtotal = 0.0
                res = ec.reservation_id
              end
            when 'Week'
              unless ec.updated_on.cweek == week
                csv_string << "subtotal,,,,,#{subtotal}\n"
                subtotal = 0.0
                week = ec.updated_on.cweek
              end
            when 'Month'
              unless ec.updated_on.month == month
                csv_string << "subtotal,,,,,#{subtotal}\n"
                subtotal = 0.0
                month = ec.updated_on.month
              end
            end
            subtotal += ec.charge
            total += ec.charge
            csv_string << "\"#{ec.reservation.space.name}\",#{ec.reservation_id},\"#{ec.reservation.camper.full_name}\",\"#{DateFmt.format_date(ec.updated_on)}\",#{ec.charge}\n"
          end
	  csv_string << "\"subtotal\",,,,,#{subtotal}\n" if subtotal
          csv_string << "\"Total\",,,,,,#{total}\n"  if total
	  csv_string << "\n"
        when Extra::COUNTED
	  debug 'Extra::COUNTED'
          # save values for subtotals
          res = @extra_charges_array[extra.id][0].reservation_id
          week = @extra_charges_array[extra.id][0].updated_on.cweek
          month = @extra_charges_array[extra.id][0].updated_on.month
          subtotal = 0.0
          # debug "subtotal 1 is #{@subtotal}"
          total = 0.0
          # generate the header string
          csv_string << "#{extra.name}\nSpace,Reservation,Name,Date,Number,Charge,Subtotal,Total\n"
          @extra_charges_array[extra.id].each do |ec|
	    ec.charge = ec.daily_charges + ec.weekly_charges + ec.monthly_charges
            case subtotal_on
            when 'Reservation'
              unless ec.reservation_id == res
                csv_string << "subtotal,,,,,,#{subtotal}\n"
                subtotal = 0.0
                res = ec.reservation_id
              end
            when 'Week'
              unless ec.updated_on.cweek == week
                csv_string << "subtotal,,,,,,#{subtotal}\n"
                subtotal = 0.0
                week = ec.updated_on.cweek
              end
            when 'Month'
              unless ec.updated_on.month == month
                csv_string << "subtotal,,,,,,#{subtotal}\n"
                subtotal = 0.0
                month = ec.updated_on.month
              end
            end
            subtotal += ec.charge
            total += ec.charge
            csv_string << "\"#{ec.reservation.space.name}\",#{ec.reservation_id},\"#{ec.reservation.camper.full_name}\",\"#{DateFmt.format_date(ec.updated_on)}\",#{ec.number},#{ec.charge}\n"
          end
	  csv_string << "\"subtotal\",,,,,,#{subtotal}\n" if subtotal
          csv_string << "\"Total\",,,,,,,#{total}\n"  if total
	  csv_string << "\n"
        when Extra::OCCASIONAL
	  debug 'Extra::OCCASIONAL'
          # save values for subtotals
          res = @extra_charges_array[extra.id][0].reservation_id
          week = @extra_charges_array[extra.id][0].updated_on.cweek
          month = @extra_charges_array[extra.id][0].updated_on.month
          subtotal = 0.0
          # debug "subtotal 1 is #{@subtotal}"
          total = 0.0
          # generate the header string
          csv_string << "#{extra.name}\nSpace,Reservation,Name,Date,Number,Charge,Subtotal,Total\n"
          @extra_charges_array[extra.id].each do |ec|
            case subtotal_on
            when 'Reservation'
              unless ec.reservation_id == res
                csv_string << "subtotal,,,,,,#{subtotal}\n"
                subtotal = 0.0
                res = ec.reservation_id
              end
            when 'Week'
              unless ec.updated_on.cweek == week
                csv_string << "subtotal,,,,,,#{subtotal}\n"
                subtotal = 0.0
                week = ec.updated_on.cweek
              end
            when 'Month'
              unless ec.updated_on.month == month
                csv_string << "subtotal,,,,,,#{subtotal}\n"
                subtotal = 0.0
                  month = ec.updated_on.month
              end
            end
            subtotal += ec.charge
            total += ec.charge
            csv_string << "\"#{ec.reservation.space.name}\",#{ec.reservation_id},\"#{ec.reservation.camper.full_name}\",\"#{DateFmt.format_date(ec.updated_on)}\",#{ec.number},#{ec.charge}\n"
          end
	  csv_string << "\"subtotal\",,,,,,#{subtotal}\n" if subtotal
          csv_string << "\"Total\",,,,,,,#{total}\n"  if total
	  csv_string << "\n"
        end
      end
      send_data(csv_string,
		:type => 'text/csv;charset=iso-8859-1;header=present',
		:disposition => "attachment; filename=Extras.csv") if csv_string.length
    else
      # debug 'processing for display'
      res = Reservation.new(params[:reservation])
      startdate = res.startdate
      enddate = res.enddate
      @subtotal_on = params[:extra][:subtotal]
      session[:startdate] = startdate
      session[:enddate] = enddate
      session[:subtotal_on] = @subtotal_on
      if params[:extras]
	str = ' AND ( '
	params[:extras].each_key {|e| str << "extra_id = \'#{e}\' OR " }
	cond,x,y = str.rpartition(' OR')
	cond << ')'
      else
        cond = ' '
        flash[:notice] = 'All extras are reported'
      end
      debug "subtotal is #{params[:extra][:subtotal]}"
      case params[:extra][:subtotal]
      when 'None'
        order = "updated_on ASC"
      when 'Reservation'
        order = "reservation_id ASC"
      when 'Week','Month'
        order = "updated_on ASC"
      else
        order = "updated_on ASC"
      end
      session[:order] = order
      session[:cond] = cond
      debug "@subtotal on is #{@subtotal_on} and order is #{order}"
      @page_title = "Extras from #{startdate} through #{enddate}"
      @extra_charges_array = extra_charges_array(startdate, enddate, order, cond)
    end
  end

private
  def extra_charges_array(startdate, enddate, order, cond)
    extra_charges = ExtraCharge.all(:conditions => ["updated_on >= ? AND updated_on <= ?" + cond, startdate, enddate], :order => order, :include => ["reservation"])
    debug "#{extra_charges.size} records found"
    if extra_charges.size == 0
      @extra_charges_array = Array.new
    else
      @extra_charges_array = extra_charges.group_by { |ec| ec.extra_id}
      end
  end

end
