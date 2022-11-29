class Report::CampersController < ApplicationController
  before_filter :login_from_cookie
  before_filter :check_login

  # GET /report_campers
  # GET /report_campers.xml
  def index
    if params[:csv]
      # generate the header line
      csv_string = 'Campers , Address ,'
      if @option.use_2nd_address?
	csv_string << 'addr2,'
      end
      csv_string << 'City, State, Mail code,'
      if @option.use_country? && Country.active.count > 0
	csv_string << 'Country,'
      end
      case @option.no_phones
	when 1
	  csv_string << 'Phone, '
	when 2
	  csv_string << 'Phone, 2nd Phone, '
      end
      csv_string << 'email address, last activity'+"\n"
      # now for the data
      Camper.all.each do |c|
	csv_string << "\"#{c.full_name}\",\"#{c.address}\","
	csv_string << "\"#{(c.address2 ? c.address2 : '')}\","  if @option.use_2nd_address?
	csv_string << "\"#{c.city}\",\"#{c.state}\",\"#{c.mail_code}\","
	if @option.use_country? && Country.active.count > 0
	  if c.country_id?
	    csv_string << (c.country.name? ? c.country.name : '') + ','
	  else
	    csv_string << ','
	  end
	end
	csv_string << (c.phone ? c.phone : '' ) + ',' if @option.no_phones > 0
	csv_string << (c.phone_2 ? c.phone_2 : '' ) + ',' if @option.no_phones > 1
	csv_string << (c.email ? c.email : '' ) + ',' + c.activity.to_s + "\n"
      end
      # debug csv_string
      send_data(csv_string,
		:type => 'text/csv;charset=iso-8859-1;header=present',
		:disposition => 'attachment; filename=Campers.csv') if csv_string.length
    else
      @page_title = "Camper Report"
      @campers = Camper.all
    end
  end
end
