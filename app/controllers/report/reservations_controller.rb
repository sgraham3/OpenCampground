class Report::ReservationsController < ApplicationController
  before_filter :login_from_cookie
  before_filter :check_login

  # GET /report_reservations/new
  # GET /report_reservations/new.xml
  def new
    @page_title = "Reservations Report Setup"
    @reservation = Reservation.new :startdate => currentDate.beginning_of_year, :enddate => currentDate.beginning_of_month
  end

  # POST /report_reservations
  # POST /report_reservations.xml
  def create
    if params[:csv]
      startdate =  session[:startdate]
      enddate =  session[:enddate]
      # generate the header line
      csv_string = '"Reservation","Site","startdate","enddate","Name","Address","City","State",'
      csv_string += '"Country",' if @option.use_country? && Country.active.count > 0
      csv_string += '"Mail Code","Email","Phone","Net","Taxes","Payments","Disposition"' + "\n"
      # now for the data
      result = get_reservations( startdate, enddate)
      result.each do |r|
	csv_string << "\"#{r.id}\",\"#{r.space.name}\",\"#{r.startdate}\",\"#{r.enddate}\",\"#{r.camper.full_name}\",\"#{r.camper.address}\",\"#{r.camper.city}\",\"#{r.camper.state}\","
	if @option.use_country? && Country.active.count > 0 
	  if r.camper.country_id? && r.camper.country.name?
	    csv_string << "\"#{r.camper.country.name}\","
	  else
	    csv_string << "\"\","
	  end
	end
	csv_string << "\"#{r.camper.mail_code}\",\"#{r.camper.email}\",\"#{r.camper.phone}\",\"#{r.total}\",\"#{r.tax_amount}\",\"#{Payment.total(r.id)}\",\"#{r.last_log_entry}#{r.close_reason}\"\n"
	
      end
      send_data(csv_string, 
		:type => 'text/csv;charset=iso-8859-1;header=present',
		:disposition => 'attachment; filename=Reservations.csv') if csv_string.length
    else
      res = Reservation.new(params[:reservation])
      @startdate = res.startdate
      @enddate   = res.enddate
      session[:startdate] = @startdate
      session[:enddate] = @enddate
      @page_title = "Reservations Report #{@startdate} to #{@enddate}"
      @result = get_reservations( @startdate, @enddate)
    end
  end
private
  def get_reservations(sd, ed)
    res = Reservation.all(:conditions => ["confirm = ? and startdate <= ? and enddate >= ?", true, ed, sd], 
                          :include => ["camper","space"], :order => :startdate)
  end
end
