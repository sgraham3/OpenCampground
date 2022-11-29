class Report::ArchivesController < ApplicationController
  before_filter :login_from_cookie
  before_filter :check_login

  # GET /report_archives/new
  # GET /report_archives/new.xml
  def new
    @page_title = "Archives Report Setup"
    @reservation = Reservation.new :startdate => currentDate.beginning_of_year, :enddate => currentDate.beginning_of_month
  end

  # POST /report_archives
  # POST /report_archives.xml
  def create
    if params[:csv]
      startdate =  session[:startdate]
      enddate =  session[:enddate]
      # generate the header line
      csv_string = '"Res #","Site","startdate","enddate","Name","Address","City","State","ZIP","Disposal","Charges","Payments"' + "\n"
      # now for the data
      result = get_archives( startdate, enddate)
      result.each do |r|
	pmt = ' '
	r.payments.each do |p|
	  pmt << p.gsub(/<.\w+>/,' ')
	end
        csv_string << "#{r.reservation_id},"
        csv_string << "\"#{r.space_name}\",\"#{r.startdate}\",\"#{r.enddate}\",\"#{r.name}\",\"#{r.address}\",\"#{r.city}\",\"#{r.state}\",\"#{r.mail_code}\""
        csv_string << ", \"#{r.last_log_entry}\", \"#{r.total_charge}\",\"#{pmt}\"\n"
      end
      send_data(csv_string,
                :type => 'text/csv;charset=iso-8859-1;header=present',
                :disposition => 'attachment; filename=Archives.csv') if csv_string.length
    else
      res = Reservation.new(params[:reservation])
      @startdate = res.startdate
      @enddate   = res.enddate
      session[:startdate] = @startdate
      session[:enddate] = @enddate
      @page_title = "Archives Report #{@startdate} to #{@enddate}"
      @result = get_archives( @startdate, @enddate)
    end
  end
private
  def get_archives(sd, ed)
    Archive.all(:conditions => ["startdate <= ? and enddate >= ?", ed, sd])
  end

  def get_log(a)
    a.chop!
    a,b,c = a.rpartition '<br/>'
    return c
  end

end
