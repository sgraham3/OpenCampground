class Report::TodayCheckinsController < ApplicationController
  before_filter :login_from_cookie
  before_filter :check_login

  # GET /report_today_checkins
  # GET /report_today_checkins.xml
  def index
    @page_title = "Arrivals scheduled #{currentDate}"
    @reservations = Reservation.all( :conditions => ["confirm = ? AND startdate = ? AND archived = ? AND checked_out = ? AND checked_in = ?",
						     true, currentDate, false, false, false],
				     :include => ['camper', 'space', 'rigtype'],
				     :order => "campers.last_name asc" )
    render 'report/today_checkins/index.html.erb'
  end
end
