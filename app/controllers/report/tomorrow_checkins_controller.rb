class Report::TomorrowCheckinsController < ApplicationController
  before_filter :login_from_cookie
  before_filter :check_login

  # GET /report_tomorrow_checkins
  # GET /report_tomorrow_checkins.xml
  def index
    @page_title = "Arrivals scheduled #{currentDate + 1}"
    @reservations = Reservation.all( :conditions => ["confirm = ? AND startdate <= ? AND archived = ? AND cancelled = ? AND checked_in = ?",
						     true, currentDate + 1, false, false, false],
				     :include => ['camper', 'space', 'rigtype'],
				     :order => "campers.last_name asc" )
    render 'report/today_checkins/index.html.erb'
  end
end
