class Report::TodayCheckoutsController < ApplicationController
  before_filter :login_from_cookie
  before_filter :check_login

  # GET /report_today_checkouts
  # GET /report_today_checkouts.xml
  def index
    @page_title = "Departures scheduled #{currentDate}"
    @reservations = Reservation.all( :conditions => ["confirm = ? AND enddate <= ? AND archived = ? AND checked_out = ? AND checked_in = ?",
						     true, currentDate, false, false, true],
				     :include => ['camper', 'space', 'rigtype'],
				     :order => "campers.last_name asc" )
    render 'report/today_checkins/index.html.erb'
  end
end
