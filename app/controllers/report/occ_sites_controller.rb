class Report::OccSitesController < ApplicationController

  # GET /report_occ_sites/new
  # GET /report_occ_sites/new.xml
  def new
    debug
    @page_title = "Site Occupancy Setup"
    @reservation = Reservation.new :startdate => currentDate.beginning_of_year, :enddate => currentDate.beginning_of_month - 1
  end

  # POST /report_occ_sites
  # POST /report_occ_sites.xml
  def create
    debug
    if params[:csv]
      @startdate =  session[:startdate]
      @enddate =  session[:enddate]
      # generate the header line
      csv_string = "\"Occupancy\",\"#{@startdate}\",\"to\",\"#{@enddate}\"\n\"Site\""
      current_date = @startdate
      while current_date < @enddate
	csv_string << ",\"#{current_date.strftime("%Y-%b")}\""
	current_date = current_date >> 1
      end
      csv_string << ",Total\n"
      # now for the data
      @result = gen_occupancy( @startdate, @enddate)
      Space.all.each do |sp|
	months = @result[sp.name]
	debug "#{months.inspect} months"
	csv_string << "\"#{sp.name}\","
	total = 0
	months.each do |m|
	  csv_string << "#{m},"
	  total += m
	end
	csv_string << "#{total}\n"
      end
      csv_string << "Total,"
      tot_occ = 0
      @total_array.each do |t|
        csv_string << "#{t},"
	tot_occ += t
      end 
      csv_string << "#{tot_occ}\n"
	  
      send_data(csv_string, 
		:type => 'text/csv;charset=iso-8859-1;header=present',
		:disposition => 'attachment; filename=Occupancy.csv') if csv_string.length
    else
      res = Reservation.new(params[:reservation])
      latest = currentDate.beginning_of_month
      @startdate = res.startdate
      session[:startdate]= @startdate
      @enddate   = res.enddate > latest ? latest : res.enddate
      session[:enddate]= @enddate
      @page_title = "Site Occupancy Report #{@startdate} to #{@enddate}"
      # create header
      dt = @startdate
      # debug "date is now #{dt}"
      @header = ['Site']
      while dt < @enddate
	@header << dt.strftime("%m/%y")
	dt >>= 1
      end
      @header << 'Total'
      @result = gen_occupancy( @startdate, @enddate)
    end
  end
private
  def gen_occupancy( startdate, enddate)
    debug "#gen_occupancy: #{startdate}, #{enddate}"
    months = enddate.month - startdate.month + 1
    months += (enddate.year - startdate.year) * 12 if startdate.year != enddate.year
    st_mo = startdate.month
    debug "#gen_occupancy: #{months} months"
    # month number of first month in report
    first_month = startdate.month
    debug "#gen_occupancy: first_month is #{first_month}"
    rhash = Hash.new
    # fetch data
    @total_array = Array.new(months,0)
    debug "#gen_occupancy: total days = #{enddate - startdate + 1}"
    debug "#gen_occupancy: month is #{startdate.month}"
    # for each space
    Space.all.each do |sp|
      sp_array = Array.new(months,0)
      #   fetch all reservations that are confirmed, checked in and are during the the period
      reservations = Reservation.all(:conditions => ["space_id = ? AND checked_in = ? AND confirm = ? AND startdate <= ? AND enddate > ?", sp.id, true, true, enddate, startdate],
				     :order => 'startdate')
      debug "#gen_occupancy: found #{reservations.size} reservations"
      #   for each of those reservations
      reservations.each do |res|
	debug "#gen_occupancy: Reservation #{res.id}"
	next if res.cancelled?
	#     for each month that is during the period get the number of days this reservation occupied the space
	c = res.ci_time
	if c
	  ci = c.to_date > startdate ? c.to_date : startdate
	else
	  debug '#gen_occupancy: no checkin time'
	  ci = res.startdate > startdate ? res.startdate : startdate
	end
	next if ci > enddate # debug "#gen_occupancy: bailing on res #{res.id}, ci (#{ci}) > enddate (#{enddate})"
	c = res.co_time
	if c
	  co = c.to_date <= enddate ? c.to_date : enddate
	else
	  debug '#gen_occupancy: no checkout time'
	  co = res.enddate <= enddate ? res.enddate : enddate 
	end
	next if co < startdate # debug "#gen_occupancy: bailing on res #{res.id}, co (#{co}) < startdate (#{startdate})"
	debug "#gen_occupancy: space #{sp.name} res #{res.id} start is #{ci}, res end is #{co} days is #{co - ci}"
	for day in ci..co
	  sp_array[day.month - st_mo] += 1 unless day == co
	end
      end
      # sum total array
      sp_array.each_index{|i| @total_array[i] += sp_array[i]}
      rhash[sp.name] = sp_array
    end
    return rhash
  end
end
