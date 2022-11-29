class Report::DuesController < ApplicationController
  before_filter :login_from_cookie
  before_filter :check_login

  # POST /report_dues
  # POST /report_dues.xml
  def index
    @reservations = Reservation.all( :conditions =>  ["confirm = ? and archived = ?",
						      true, false])
    if params[:csv]
      # generate header
      csv_string = "Res # ,Space ,Camper ,Total ,Paid ,Due\n"
      @reservations.each do |res|
	csv_string << "#{res.id} ,\"#{res.space.name}\" ,\"#{res.camper.full_name}\" ,"
	due = 0.0
	total = 0.0
	pmt = Payment.total(res.id)
	if @option.use_override? && (res.override_total > 0.0)
	  total = res.override_total
	else
	  total = res.total + res.tax_amount
	end
	due = total - pmt
	csv_string << sprintf("%10.2f", total) + ','
	csv_string << sprintf("%10.2f", pmt) + ','
	csv_string << sprintf("%10.2f", due) + "\n"
      end
      send_data(csv_string,
		:type => 'text/csv;charset=iso-8859-1;header=present',
		:disposition => 'attachment; filename=Due.csv') if csv_string.length
    else
      @page_title = 'Amounts Due'
    end
  end
end
