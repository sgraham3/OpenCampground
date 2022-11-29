class Report::PaymentsController < ApplicationController
  before_filter :login_from_cookie
  before_filter :check_login
  include ApplicationHelper

  # GET /report_payments/new
  # GET /report_payments/new.xml
  def new
    @page_title = "Payments Report Definition"
    @reservation = Reservation.new
    @reservation.startdate = currentDate
    @reservation.enddate = currentDate
    @today = true
    @yesterday = false
    @l_week = false
    @l_month = false
    @l_year = false
    @payment = Payment.new
  end

  # POST /report_payments
  # POST /report_payments.xml
  def create
    startdate = session[:startdate]
    enddate = session[:enddate]
    sort = session[:sort]
    if params[:csv]
      csv_string = Payment.csv(startdate, enddate, sort) 
      send_data(csv_string,
		:type => 'text/csv;charset=UTF-8;header=present',
		:disposition => 'attachment; filename=Payments.csv') if csv_string.size > 0
    elsif params[:bsa]
      csv_string = Payment.bsa(startdate, enddate, sort) 
      send_data(csv_string,
		:type => 'text/csv;charset=UTF-8;header=present',
		:disposition => 'attachment; filename=Payments.csv') if csv_string.size > 0
    elsif params[:qif]
      csv_string = Payment.qif(startdate, enddate, sort) 
      send_data(Payment.qif(startdate, enddate, sort), 
		:type => 'text;charset=UTF-8;header=present',
		:disposition => 'attachment; filename=Payments.qif') if csv_string.size > 0
    elsif params[:tp]
      csv_string = Payment.tp(startdate, enddate, sort) 
      send_data(Payment.tp(startdate, enddate, sort), 
		:type => 'text;charset=UTF-8;header=present',
		:disposition => 'attachment; filename=Payments.csv') if csv_string.size > 0
    else
      @res = Reservation.new(params[:reservation])
      session[:startdate] = @res.startdate
      session[:enddate] = @res.enddate
      @sort = params[:payment][:subtotal]
      session[:sort] = @sort
      @payments = 0.0
      if @res.startdate == @res.enddate
	@page_title = "Payments for #{@res.startdate} sorted by #{@sort}"
      else
	@page_title = "Payments for #{@res.startdate} thru #{@res.enddate} sorted by #{@sort}"
      end
      case @sort
      when 'None'
	order = 'reservation_id'
      when 'Reservation'
	order = 'reservation_id,pmt_date'
      when 'Month', 'Week'
	order = 'pmt_date'
      when 'Payment Type'
	order = 'creditcard_id,pmt_date'
      end

      @payments = Payment.all(:conditions => ["pmt_date >= ? AND pmt_date < ?",
					      @res.startdate.to_datetime.at_midnight,
					      @res.enddate.tomorrow.to_datetime.at_midnight],
			      :include => ['reservation','creditcard'],
			      :order => order )
      unless @payments.size > 0 
	flash[:notice] = "No payments for #{@res.startdate} thru #{@res.enddate}"
	redirect_to new_report_payment_url
      else
	@subtotal = 0.0
	@net_sub = 0.0
	@tax_sub = 0.0
	@first_time = true
	@count = 0
	@res = 0
	@week =  @payments[0].pmt_date.to_date.cweek
	@dt = @payments[0].pmt_date.to_date
	@month = @dt.month
	@card =  @payments[0].creditcard_id
	debug @card.inspect
	@cardname =  @payments[0].creditcard.name
      end
    end
  end

  # PUT /report_payments/1
  # PUT /report_payments/1.xml
  def update
    @reservation = Reservation.new
    case params[:when]
    when 'today'
      @reservation.startdate = currentDate
      @reservation.enddate = currentDate
      @today = true
      @yesterday = false
      @l_week = false
      @l_month = false
      @l_year = false
    when 'yesterday'
      @reservation.startdate = currentDate.yesterday
      @reservation.enddate = currentDate.yesterday
      @today = false
      @yesterday = true
      @l_week = false
      @l_month = false
      @l_year = false
    when 'l_week'
      # wk = currentDate.cweek
      # wk -= 1
      sd,ed = get_dates_from_week(currentDate.year, currentDate.cweek - 1, 1)
      ed -= 1.day
      debug "sd #{sd}, ed #{ed}"
      @reservation.startdate = sd
      @reservation.enddate = ed
      @today = false
      @yesterday = false
      @l_week = true
      @l_month = false
      @l_year = false
    when 'l_month'
      dt = currentDate.change(:month => (currentDate.month - 1))
      debug "dt #{dt}"
      @reservation.startdate = dt.beginning_of_month
      @reservation.enddate = dt.end_of_month
      @today = false
      @yesterday = false
      @l_week = false
      @l_month = true
      @l_year = false
    when 'l_year'
      year = currentDate.year
      year -= 1
      @reservation.startdate = Date.new( year, 1, 1)
      @reservation.enddate = Date.new( year, 12, 31)
      @today = false
      @yesterday = false
      @l_week = false
      @l_month = false
      @l_year = true
    else
    end
    debug "#{@reservation.startdate}, #{@reservation.enddate}"
    render :update do |page|
      page[:dates].replace_html :partial => 'report/shared/dates'
    end
  end
end
