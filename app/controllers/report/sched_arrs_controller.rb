class Report::SchedArrsController < ApplicationController
  before_filter :login_from_cookie
  before_filter :check_login

  # GET /report_sched_arrs/new
  # GET /report_sched_arrs/new.xml
  def new
    @page_title = "Scheduled Arrivals Selection"
    @reservation = Reservation.new :startdate => currentDate+1, :enddate => currentDate+1
  end

  # POST /report_sched_arrs
  # POST /report_sched_arrs.xml
  def create
    res = Reservation.new params[:reservation]
    startdate = res.startdate
    enddate   = res.enddate

    debug "startdate = #{startdate} and enddate = #{enddate}"
    if startdate == enddate
      @page_title = "Arrivals scheduled #{startdate}"
      @reservations = Reservation.all( :conditions => ["confirm = ? AND startdate >= ? AND startdate <= ? AND archived = ? AND checked_in = ?",
						       true, startdate, enddate, false, false],
				       :include => ['camper', 'space', 'rigtype'],
				       :order => "campers.last_name asc" )
    else
      @page_title = "Arrivals scheduled #{startdate} thru #{enddate}"
      @reservations = Reservation.all( :conditions => ["confirm = ? AND startdate >= ? AND startdate <= ? AND archived = ? AND checked_in = ?",
						       true, startdate, enddate, false, false],
				       :include => ['camper', 'space', 'rigtype'],
				       :order => "startdate,spaces.position asc" )
    end
    render 'report/today_checkins/index.html.erb'
  end
end
