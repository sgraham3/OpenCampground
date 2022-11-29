class Report::AvailablesController < ApplicationController
  before_filter :login_from_cookie
  before_filter :check_login
  before_filter :clear_session

  # provide a table of spaces available
  # only update function is relevent
  #
  # GET /availables
  # GET /availables.xml
  def update
    debug
    if params[:id] == 'csv'
      debug 'have csv'
      session[:reservation_id] = nil
      csv_string = header_av_csv
      @spaces = Space.active
      @spaces.each do |s|
	csv_string << space_av_csv(s)
      end
      send_data(csv_string,
		:type => 'text/csv;charset=iso-8859-1;header=present',
		:disposition => 'attachment; filename=Available.csv')
    else
      debug 'standard display'
      @page_title = I18n.t('titles.site_av')
      #########################################################
      #
      # build an array of arrays of all spaces with array of reservations
      #
      #########################################################

      if @option.use_park_closed?
	@closedStart = @option.closed_start.change(:year => currentDate.year)
	@closedEnd = @option.closed_end.change(:year => currentDate.year)
	if @closedEnd > @closedStart
	  # start and end are in the same year
	  if currentDate > @closedEnd
	    @closedStart = @option.closed_start.change(:year => (currentDate.year + 1))
	    @closedEnd = @option.closed_end.change(:year => (currentDate.year + 1))
	  end
	  debug "Closed summer"
	  @closedSummer = true
	else
	  # start is in one year and end is in the next year
	  @closedEnd = @option.closed_end.change(:year => (currentDate.year + 1))
	  if currentDate > @closedEnd
	    @closedStart = @option.closed_start.change(:year => (currentDate.year + 1))
	    @closedEnd = @option.closed_end.change(:year => (currentDate.year + 2))
	  else
	    @closedEnd = @option.closed_end.change(:year => (currentDate.year + 1))
	  end
	  debug "Closed winter"
	  @closedSummer = false
	  @days_closed = @closedEnd - @closedStart
	  debug "closed #{@days_closed} days"
	end
      end

      @spaces = Space.active
      res = Reservation.all( :conditions => [ "(enddate >= ? or checked_in = ?) and archived = ?",currentDate - @option.lookback.days, true, false],
			     :include => ['camper'],
			     :order => "space_id,startdate ASC")
      @res = res.group_by{|sp|sp.space_id}
    end
  end

  private

  def header_av_csv
    start_date = currentDate - @option.lookback.to_i
    days = @option.sa_columns
    ret_str = 'Space'
    enddate = start_date + days
    date = start_date
    while date < enddate
      ret_str << ';'
      ret_str << "\"" + I18n.l(date) + "\""
      date = date.succ
    end
    ret_str << "\n"
  end

  def space_av_csv(space)
    # o = occupied
    # r = reserved
    # - = available
    #############################################
    # space is the space we are currently 
    # building up the string for, res_array
    # is the array of all confirmed reservations
    # ordered by space_id and startdate
    #############################################
    start_date = currentDate - @option.lookback
    days = @option.sa_columns
    enddate = start_date + days
    date = start_date
    res = Reservation.all( :conditions => [ "space_id = ? AND enddate >= ? AND confirm = ? AND archived = ?",space.id, start_date, true, false],
			   :order => "startdate ASC")
    ret_str = "\"" + space.name + "\""

    # for each date from start_date to enddate
    # if res empty
    #  output -
    # elsif current => res[0].start and current < res[0]end
    # elsif current == res[0].end
    #  shift res[1] to res[0]
    #  if res.empty output -
    #  elsif current == res[0].start
    #    output o
    #  else
    #    output -
    #  end
    # end

    while date < enddate
      if res.empty?
        ret_str << ";\"-\""
      elsif date >= res[0].startdate && date < res[0].enddate
        if res[0].checked_in?
	  ret_str << ";\"O\""
	else
	  ret_str << ";\"R\""
	end
      elsif date == res[0].enddate
        res.shift
	if !res.empty? && date == res[0].startdate
	  if res[0].checked_in?
	    ret_str << ";\"O\""
	  else
	    ret_str << ";\"R\""
	  end
	else
	  ret_str << ";\"-\""
	end
      else
	ret_str << ";\"-\""
      end
      date = date.succ
    end
    ret_str << "\n"
  end

end
