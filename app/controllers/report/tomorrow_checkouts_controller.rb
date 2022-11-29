class Report::TomorrowCheckoutsController < ApplicationController
  before_filter :login_from_cookie
  before_filter :check_login

  # GET /report_tomorrow_checkouts
  # GET /report_tomorrow_checkouts.xml
  def index
    @page_title = "Departures scheduled #{currentDate + 1}"
    @reservations = Reservation.all( :conditions => ["confirm = ? AND enddate <= ? AND cancelled = ? AND archived = ?",
						     true, currentDate + 1, false, false],
				     :include => ["camper", 'space', 'rigtype'],
				     :order => "campers.last_name asc" )
    render 'report/today_checkins/index.html.erb'
  end
end
