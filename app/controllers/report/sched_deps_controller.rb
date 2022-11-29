class Report::SchedDepsController < ApplicationController
  before_filter :login_from_cookie
  before_filter :check_login

  # GET /report_sched_deps/new
  # GET /report_sched_deps/new.xml
  def new
    @page_title = "Scheduled Departures Selection"
    @reservation = Reservation.new
    @reservation.startdate = currentDate+1
    @reservation.enddate = currentDate+1
  end

  # POST /report_sched_deps
  # POST /report_sched_deps.xml
  def create
    res = Reservation.new params[:reservation]
    startdate = res.startdate
    enddate   = res.enddate

    debug "startdate = #{startdate} and enddate = #{enddate}"
    if startdate == enddate
      @page_title = "Departures scheduled #{startdate}"
      @reservations = Reservation.all( :conditions => ["confirm = ? AND enddate >= ? AND enddate <= ? AND checked_in = ? AND checked_out = ? AND cancelled = ? AND archived = ?",
						       true, startdate, enddate, true, false, false, false],
				       :include => ["camper", 'rigtype', 'space'],
				       :order => "campers.last_name asc" )
    else
      @page_title = "Departures scheduled #{startdate} thru #{enddate}"
      @reservations = Reservation.all( :conditions => ["confirm = ? AND enddate >= ? AND enddate <= ? AND checked_in = ? AND checked_out = ? AND cancelled = ? AND archived = ?",
						       true, startdate, enddate, true, false, false, false],
				       :include => ['camper', 'space', 'rigtype'],
				       :order => "enddate,spaces.position asc" )
    end
    render 'report/today_checkins/index.html.erb'
  end
end
