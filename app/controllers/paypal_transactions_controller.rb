class PaypalTransactionsController < ApplicationController

  layout :determine_layout

  # GET /paypal_transactions/new
  def new
    @page_title = 'Pay with PayPal'
    # post the full value
    @reservation = Reservation.find params[:reservation_id]
    @paypal_transaction = PaypalTransaction.new :reservation_id => params[:reservation_id],
                                                :amount => @reservation.due.round(2)
  end

  # POST /paypal_transactions/create
  def create
    # debug "Controller: #{params[:controller]}"
    # debug "Params: #{params[:paypal_transaction]}"
    unless params[:paypal_transaction][:amount].to_f > 0.0
      flash[:error] = "Invalid charge, amount is #{params[:paypal_transaction][:amount]}"
      redirect_to :controller => :reservation,
		  :action => :show,
		  :reservation_id => params[:paypal_transaction][:reservation_id] and return
    end
    @transaction = PaypalTransaction.create params[:paypal_transaction]
    wfc = wait_for_confirm_paypal_transaction_url(@transaction.reservation_id)
    ipn = ipn_paypal_transactions_url
    encrypted = @transaction.fetch_decrypted(wfc, ipn)
    action_url = Rails.env.production? ? Integration.first.pp_url : "https://www.sandbox.paypal.com/cgi-bin/webscr"
    @transaction.update_attributes :encrypted => encrypted, :url => action_url
  end

  # GET /paypal_transactions/wait_for_confirm
  def wait_for_confirm
    # wait for confirm
    unless session[:count]
      session[:count] = 1
    else
      session[:count] += 1
    end
    info "high wait_for_confirm count #{session[:count]}" if session[:count] > 18
    begin
      @prompt = Prompt.find_by_display_and_locale!('wait_for_confirm', I18n.locale.to_s)
    rescue
      @prompt = Prompt.find_by_display_and_locale('wait_for_confirm', 'en')
    end
    begin
      if params[:invoice]
	# info 'got invoice ' + params[:invoice]
	@reservation = Reservation.find(params[:invoice])
      elsif params[:id]
	# info 'got id ' + params[:id]
	@reservation = Reservation.find(params[:id])
      else
	# now what?
	error 'did not get id or invoice'
	# just fall through for now
      end
    rescue ActiveRecord::RecordNotFound
      error "reservation #{res_id}"
      @message = 'Error--unable to find your transaction! Please contact us directly.'
      render :action => 'payment_error' and return
    end
    if @reservation.confirm? || session[:count] >= 24
      if session[:count] >= 24
	# paypal took over 2 minutes
        error "paypal timed out"
	flash[:error] = "PayPal transaction timed out"
	@reservation.add_log("PayPal transaction timed out")
      else
	@reservation.add_log("paid with PayPal")
      end
      session[:count] = nil
      if @remote
	redirect_to :controller => :remote, :action => :confirmation and return
      else
	redirect_to :controller => :reservation, :action => :confirm_res, :reservation_id => @reservation.id and return
      end
    end
  rescue => err
    error err.to_s
  end

  # GET /paypal_transactions/ipn
  def ipn
    # handle the ipn
    # Instant Payment Notification processing from PayPal
    transaction = PaypalTransaction.find_by_reservation_id(params[:invoice])
    transaction.handle(request, params)
  rescue => err
    error err.to_s
  ensure
    render :nothing => true
  end

private

  def determine_layout
    if @remote
      'remote'
    else
      'application'
    end
  end

end
