class Report::CardTransactionsController < ApplicationController
  before_filter :login_from_cookie
  before_filter :check_login
  include Report::CardTransactionsHelper

  # GET /report_card_transactions/new
  # GET /report_card_transactions/new.xml
  def new
    @page_title = "Credit Card Transactions Report Definition"
    @reservation = Reservation.new
    @reservation.startdate = currentDate
    @reservation.enddate = currentDate
    @card_transaction = CardTransaction.new
  end

  # POST /report_card_transactions
  # POST /report_card_transactions.xml
  def create
    if params[:csv]
      startdate = session[:startdate]
      enddate = session[:enddate]
      if startdate == enddate
	csv_string = '"Credit Card",' + " #{startdate}\n"
      else
	csv_string = '"Credit Card",' + startdate.to_s + " thru " +  enddate.to_s + "\n"
	csv_string = "\"Credit Card\",#{startdate.to_s},\" thru \",#{enddate.to_s}\n"
      end
      @card_transactions = CardTransaction.all(:conditions =>["created_at > ? AND created_at < ?",
							      startdate.to_datetime.at_midnight,
							      enddate.tomorrow.to_datetime.at_midnight],
					      :include => ['reservation'],
					      :order => 'reservation_id, retref, respproc')
      csv_string << '"Res #", "Camper", "Date/Time", "Card", "Card No.", "Ref No.", "Status", "Charges"'
      csv_string << "\n"
      @card_transactions.each do |p|
	unless p.account.blank?
	  res = get_res p.reservation_id
	  csv_string << "#{res.id}, \"#{res.camper.full_name}\", \"#{p.created_at}\", \"#{Creditcard.card_type(p.account[1].chr)}\","
	  csv_string << "\"#{'****' + p.account[-4..-1]}\", \"#{p.retref}\", \"#{p.resptext}\", \"#{number_2_currency(p.amount)}\"\n"
	end 
      end 
      send_data(csv_string,
		:type => 'text/csv;charset=iso-8859-1;header=present',
		:disposition => 'attachment; filename=CardTransactions.csv') if csv_string.length
    else
      @res = Reservation.new(params[:reservation])
      session[:startdate] = @res.startdate
      session[:enddate] = @res.enddate
      if @res.startdate == @res.enddate
	@page_title = "Credit Card Transactions for #{@res.startdate}"
      else
	@page_title = "Credit Card Transactions for #{@res.startdate} thru #{@res.enddate}"
      end
      @card_transactions = CardTransaction.all(:conditions =>["created_at > ? AND created_at < ?",
							      @res.startdate.to_datetime.at_midnight,
							      @res.enddate.tomorrow.to_datetime.at_midnight],
					      :include => ['reservation'],
					      :order => 'reservation_id, retref, respproc')
    end
  end
end
