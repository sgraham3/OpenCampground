class Report::TransactionsController < ApplicationController
  before_filter :login_from_cookie
  before_filter :check_login

  # GET /report_transactions/new
  # GET /report_transactions/new.xml
  def new
    @page_title = "Transactions Selection"
    @reservation = Reservation.new
    @reservation.startdate = currentDate
    @reservation.enddate = currentDate
  end

  # POST /report_transactions
  # POST /report_transactions.xml
  def create
    if params[:csv]
      startdate = session[:startdate]
      enddate = session[:enddate]
      get_transactions(startdate, enddate)
      discounts = Discount.count :conditions => ["active = ?",true]
      recommendations = @option.use_recommend?
      csv_string = '"Occurance","Reservation","Space","Camper","Start date","End date",'
      csv_string << '"Discount",' if discounts > 0
      csv_string << '"Recommender",' if recommendations
      csv_string << "\"Description\"\n"
      @new_res.each do |res|
	st_ = res.startdate.strftime("%m/%d/%Y")
	end_ = res.enddate.strftime("%m/%d/%Y")
	csv_string << "\"New\",\"#{res.id}\",\"#{res.space.name}\",\"#{res.camper.full_name}\",#{st_},#{end_ },"
	csv_string << (res.discount_id > 0 ? "#{res.discount.name}," : '"",') if discounts > 0
	csv_string << (res.recommender_id > 0 ? "#{res.recommender.name}," : '"",') if recommendations
	csv_string << "\"#{res.last_log_entry('reservation')}\"\n"
      end
      @checkins.each do |res|
	st_ = res.startdate.strftime("%m/%d/%Y")
	end_ = res.enddate.strftime("%m/%d/%Y")
	csv_string << "\"Check-in\",\"#{res.id}\",\"#{res.space.name}\",\"#{res.camper.full_name}\",#{st_},#{end_ },"
	csv_string << (res.discount_id > 0 ? "#{res.discount.name}," : '"",') if discounts > 0
	csv_string << (res.recommender_id > 0 ? "#{res.recommender.name}," : '"",') if recommendations
	csv_string << "\"#{res.last_log_entry('checkin')}\"\n"
      end
      @checkouts.each do |res|
	st_ = res.startdate.strftime("%m/%d/%Y")
	end_ = res.enddate.strftime("%m/%d/%Y")
	csv_string << "\"Check-out\",\"#{res.id}\",\"#{res.space.name}\",\"#{res.camper.full_name}\",#{st_},#{end_ },"
	csv_string << (res.discount_id > 0 ? "#{res.discount.name}," : '"",') if discounts > 0
	csv_string << (res.recommender_id > 0 ? "#{res.recommender.name}," : '"",') if recommendations
	csv_string << "\"#{res.last_log_entry('checkout')}\"\n"
      end
      @cancels.each do |res|
	st_ = res.startdate.strftime("%m/%d/%Y")
	end_ = res.enddate.strftime("%m/%d/%Y")
	csv_string << "\"Cancel\",\"#{res.id}\",\"#{res.space.name}\",\"#{res.camper.full_name}\",#{st_},#{end_ },"
	csv_string << (res.discount_id > 0 ? "#{res.discount.name}," : '"",') if discounts > 0
	csv_string << (res.recommender_id > 0 ? "#{res.recommender.name}," : '"",') if recommendations
	csv_string << "\"#{res.last_log_entry('cancel')}\"\n"
      end
      @changes.each do |res|
	st_ = res.startdate.strftime("%m/%d/%Y")
	end_ = res.enddate.strftime("%m/%d/%Y")
	change_array = res.all_log_entries('changed')
	change_array.each do |c|
	  csv_string << "\"Change\",\"#{res.id}\",\"#{res.space.name}\",\"#{res.camper.full_name}\",#{st_},#{end_ },"
	  csv_string << (res.discount_id > 0 ? "#{res.discount.name}," : '"",') if discounts > 0
	  csv_string << (res.recommender_id > 0 ? "#{res.recommender.name}," : '"",') if recommendations
	  csv_string << "\"#{c}\"\n"
	end
      end
      send_data(csv_string, 
		:type => 'text/csv;charset=iso-8859-1;header=present',
		:disposition => 'attachment; filename=Transactions.csv') if csv_string.length
    else
      @res = Reservation.new(params[:reservation])
      if @res.startdate == @res.enddate
	@page_title = "Transactions for #{DateFmt.format_date(@res.startdate,'long')}"
      else
	@page_title = "Transactions for #{DateFmt.format_date(@res.startdate,'long')} to #{DateFmt.format_date(@res.enddate,'long')}"
      end
      session[:startdate] = @res.startdate
      session[:enddate] = @res.enddate
      @summary = params[:control][:button] == 'Summary'? true : false
      if params[:download] && params[:download] == "true"
	transactions_csv(@res.startdate, @res.enddate) 
      else
	if @res.startdate == @res.enddate
	  @page_title = "Transactions for #{@res.startdate}"
	else
	  @page_title = "Transactions for #{@res.startdate} thru #{@res.enddate}"
	end
	get_transactions(@res.startdate, @res.enddate)
      end
    end
  end

private

  def get_transactions(startdate, enddate)
    # debug 'get_transactions'
    # get new reservations
    @new_res = Reservation.all(:conditions => ["confirm = ? and CREATED_AT >= ? AND CREATED_AT <= ?",
                                                true, startdate, enddate.tomorrow],
				:include => "space",
                                :order => "created_at asc")
    # get checkins
    @checkins = Reservation.all(:conditions => ["confirm = ? and checked_in = ? and STARTDATE >= ? AND STARTDATE <= ?",
                                                 true, true, startdate, enddate],
				 :include => "space",
                                 :order => "startdate asc")
    # get checkouts
    @checkouts = Reservation.all(:conditions => ["confirm = ? and checked_in = ? and checked_out = ? and ENDDATE >= ? AND ENDDATE <= ? and LOG like '%checkout%'",
                                                 true, true, true, startdate, enddate],
				 :include => "space",
                                 :order => "enddate asc")
    # get cancels
    @cancels = Reservation.all(:conditions => ["confirm = ? and cancelled = ? and CREATED_AT >= ? AND UPDATED_AT <= ? and LOG like '%cancelled%'",
                                                 true, true, startdate, enddate],
			       :include => "space",
                               :order => "updated_at asc")
    # need to remove uncancel and restrict to cancels

    # get changes
    changes = Reservation.all(:conditions => ["confirm = ? and CREATED_AT >= ? AND UPDATED_AT <= ? and LOG like ?",
                                                 true, startdate, enddate, '%changed%'],
			       :include => "space",
                               :order => "startdate asc")
    # need to filter to include only changes .. one record for each change  
    @changes = []
    changes.each do |c|
      ent = c.all_log_entries('changed')
      ent.reverse_each do |e|
        if e =~ /changed/
          cc = c.clone
          cc.log = e
          cc.id = c.id
          @changes << cc
        end
      end
    end
    # debug "@changes.size = #{@changes.size}, changes.size = #{changes.size}"
  end
end
