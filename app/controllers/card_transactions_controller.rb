class CardTransactionsController < ApplicationController
  # GET /card_transactions
  # GET /card_transactions.xml
  require 'pp'

  def index
    @card_transactions = CardTransaction.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @card_transactions }
    end
  end

  # GET /card_transactions/1
  # GET /card_transactions/1.xml
  def show
    @card_transaction = CardTransaction.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @card_transaction }
    end
  end

  # GET /card_transactions/new
  # GET /card_transactions/new.xml
  def new
    @page_title = 'Pay with CardConnect'
    info "mobile is #{@mobile}"
    info "user agent is #{request.user_agent}"
    @integration = Integration.first
    reservation = Reservation.find params[:card_transaction][:reservation_id]
    # create a card transaction
    debug 'create a card transaction'
    @card_transaction = CardTransaction.new(params[:card_transaction].merge(:amount => reservation.due.round(2)))
    debug @card_transaction.inspect
  end

  # GET /card_transactions/1/edit
  def edit
    @card_transaction = CardTransaction.find(params[:id])
  end

  # POST /card_transactions
  # POST /card_transactions.xml
  def create
    begin
      res = Reservation.find(params[:card_transaction][:reservation_id])
    rescue ActiveRecord::RecordNotFound
      flash[:error] = "Reservation idle over 30 minutes.  Starting over"
      if @remote
        redirect_to :controller => :remote, :action => :index and return
      else
	redirect_to :controller => :reservation, :action => :index and return
      end
    end
    if (params[:card_transaction][:process_mode] == CardTransaction::TokenLocal ||
	params[:card_transaction][:process_mode] == CardTransaction::TokenRemote) &&
	params[:card_transaction][:account].empty?
      debug 'no account number'
      flash[:error] = "Error in card processing, please enter again"
      if @remote
        redirect_to :controller => :remote, :action => :payment, :reservation_id => res.id and return
      else
	redirect_to :controller => 'card_transactions', :action => 'new', :card_transaction => {:reservation_id => res.id, :process_mode => params[:card_transaction][:process_mode]} and return
      end
    end
    unless params[:card_transaction][:amount].to_f > 0.0
      if @remote
        redirect_to :controller => :remote, :action => :show, :reservation_id => res.id and return
      else
	flash[:error] = "Invalid charge, amount is #{params[:card_transaction][:amount]}"
	redirect_to :controller => :reservation, :action => :show, :reservation_id => res.id and return
      end
    end
    if params[:card_transaction]["expiry(1i)"]
      exp_yr = params[:card_transaction]["expiry(1i)"].to_i - 2000 # we will now have a 2 digit year.
      exp_mo = params[:card_transaction]["expiry(2i)"].to_i
      params[:card_transaction].delete("expiry(1i)")
      params[:card_transaction].delete("expiry(2i)")
      params[:card_transaction].delete("expiry(3i)")
      ex_dt = sprintf("%02d",exp_mo) + sprintf("%02d", exp_yr)
      debug "expiration date mmyy is #{ex_dt}"
      card_transaction = CardTransaction.create(params[:card_transaction].merge(:expiry => ex_dt))
    else
      card_transaction = CardTransaction.create(params[:card_transaction])
    end
    debug 'created'
    err = card_transaction.errors_in_transaction
    if err.empty?
      # no error
    else
      debug 'processing error'
      message = 'create error: '
      flash[:error] =  message + err
      error message + err
      if card_transaction.process_mode == CardTransaction::TokenRemote
	redirect_to :controller => :remote, :action => :payment and return
      else
	redirect_to :controller => :reservation, :action => :show, :reservation_id => card_transaction.reservation_id and return
      end
    end
    debug 'created'
    debug "process mode is #{card_transaction.process_mode}"
    case card_transaction.process_mode
    when CardTransaction::TokenLocal, CardTransaction::TokenRemote
      debug 'CardTransaction::TokenLocal, CardTransaction::TokenRemote'
      # a tokenized transaction
      # and we will process an authorize
      resp = card_transaction.authorize
      err = card_transaction.errors_in_transaction
      if err.empty?
        # no error
      else
	debug "err in authorize is #{err}"
	message = 'processing error: '
	flash[:error] =  message + err
	error message + err
	if card_transaction.process_mode == CardTransaction::TokenRemote
	  redirect_to :controller => :remote, :action => :payment, :reservation_id => card_transaction.reservation_id and return
	else
	  redirect_to :controller => :reservation, :action => :show, :reservation_id => card_transaction.reservation_id and return
	end
      end
      debug 'completed authorize'
      debug "card_transaction id is #{card_transaction.id}, reservation_id is #{card_transaction.reservation_id}, success = #{resp.success?}"
      if resp.class == Faraday::Response && resp.success?
	# communication was successful
	if card_transaction.respstat == 'A'
	  info 'transaction approved'
	  Reservation.find(card_transaction.reservation_id).add_log("paid with CardConnect")
	  flash[:notice] = "Transaction approved"
	  # record payment
	  # store payment details
	  # ref no etc are in the card_transaction
	  # debug "account is #{card_transaction.account}"
	  creditcard_name = Creditcard.card_type(card_transaction.account[1].chr)
	  # debug "creditcard name is #{creditcard_name}"
	  creditcard_id = Creditcard.find_or_create_by_name(creditcard_name).id
	  # debug "creditcard_id is #{creditcard_id}"
	  p = Payment.create(:reservation_id => card_transaction.reservation_id,
			    :credit_card_no => '****' + card_transaction.account[-4..-1],
			    :creditcard_id => creditcard_id,
			    :amount => card_transaction.amount,
			    :cc_expire => Date.strptime(card_transaction.expiry,"%m%y").at_end_of_month,
			    :refundable => true,
			    :memo => "card not present, retref #{card_transaction.retref}")
	  # card_transaction.reservation.update_attributes :confirm => true
	  card_transaction.update_attributes :payment_id => p.id
	else
	  debug "Transaction not approved: #{card_transaction.resptext} (code #{card_transaction.respcode})"
	  flash[:error] = "Transaction not approved: #{card_transaction.resptext} (code #{card_transaction.respcode})"
	  @success = false
	  if card_transaction.process_mode == CardTransaction::TokenRemote
	    redirect_to :controller => :remote, :action => :payment, :reservation_id => card_transaction.reservation_id and return
	  else
	    # redirect_to :controller => :reservation, :action => :show, :reservation_id => card_transaction.reservation_id and return
	  end
	end
      else
        err = card_transaction.errors_in_transaction
	if err.empty?
	  # no error so why are we here?
	else
	  message = 'communication error: '
	  flash[:error] =  message + err
	  error message + err

	  if card_transaction.process_mode == CardTransaction::TokenRemote
	    redirect_to :controller => :remote, :action => :payment, :reservation_id => card_transaction.reservation_id and return
	  else
	    redirect_to :controller => :reservation, :action => :show, :reservation_id => card_transaction.reservation_id and return
	  end
	end
      end
      redirect_to :controller => :remote, :action => :confirmation and return if card_transaction.process_mode == CardTransaction::TokenRemote
    when CardTransaction::TermCard, CardTransaction::TermManual
      debug 'CardTransaction::TermCard, CardTransaction::TermManual'
      # card processing
      if card_transaction.process_mode == CardTransaction::TermCard
	debug 'card present processing'
	resp = card_transaction.authCard
	err = card_transaction.errors_in_transaction
	if err.empty?
	  # no error
	else
	  message = 'processing error: '
	  flash[:error] =  message + err
	  error message + err
	  redirect_to :controller => :reservation, :action => :show, :reservation_id => card_transaction.reservation_id and return
	end
	debug 'completed authCard'
      else
        # CardTransaction::TermManual
	debug 'manual processing'
	resp = card_transaction.authManual
	err = card_transaction.errors_in_transaction
	if err.empty?
	  # no error
	else
	  message = 'processing error: '
	  flash[:error] =  message + err
	  error message + err
	  redirect_to :controller => :reservation, :action => :show, :reservation_id => card_transaction.reservation_id and return
	end
	debug 'completed authManual'
      end
      if resp.class == Faraday::Response && resp.success?
	debug 'comm status success'
	# communication was successful
	if card_transaction.approved?
	  info 'transaction approved'
	  flash[:notice] = "Transaction approved"
	  Reservation.find(card_transaction.reservation_id).add_log("paid with CardConnect")
	  # record payment
	  # store payment details
	  # ref no etc are in the card_transaction
	  # debug "account is #{card_transaction.account}"
	  creditcard_name = Creditcard.card_type(card_transaction.account[1].chr)
	  # debug "creditcard name is #{creditcard_name}"
	  creditcard_id = Creditcard.find_or_create_by_name(creditcard_name).id
	  # debug "creditcard_id is #{creditcard_id}"
	  memo = card_transaction.card_present?
	  if card_transaction.process_mode == CardTransaction::TermCard 
	    memo = 'card present, ' 
	  else
	    memo = 'card not present, '
	  end
	  p = Payment.create(:reservation_id => card_transaction.reservation_id,
			    :credit_card_no => '****' + card_transaction.account[-4..-1],
			    :creditcard_id => creditcard_id,
			    :amount => card_transaction.amount,
			    :cc_expire => Date.strptime(card_transaction.expiry,"%m%y").at_end_of_month,
			    :refundable => true,
			    :memo => memo + "retref #{card_transaction.retref}") 
	  card_transaction.update_attributes :payment_id => p.id
	else
	  debug "Transaction not approved: #{card_transaction.resptext} (code #{card_transaction.respcode[1..2]})"
	  flash[:error] = "Transaction not approved: #{card_transaction.resptext} (code #{card_transaction.respcode[1..2]})"
	end
      else
        err = card_transaction.errors_in_transaction
	if err.empty?
	  # no errors
	else
	  flash[:error] = "communication problem: #{err}"
	  redirect_to(:controller => 'reservation', :action => 'show', 
		      :reservation_id => card_transaction.reservation_id) and return
	end
	if card_transaction.process_mode == CardTransaction::TokenRemote
	  redirect_to :controller => :remote, :action => :payment, :reservation_id => card_transaction.reservation_id and return
	else
	  redirect_to :controller => :reservation, :action => :show, :reservation_id => card_transaction.reservation_id and return
	end
        handle_other_error card_transaction
      end
    end
    if card_transaction.receiptData?
      redirect_to payment_receipt_url(card_transaction.id) and return
    else
      redirect_to(:controller => 'reservation', :action => 'show', 
		  :reservation_id => card_transaction.reservation_id) and return
    end
  end

  # PUT /card_transactions/1
  # PUT /card_transactions/1.xml
  def update
    @card_transaction = CardTransaction.find(params[:id])
    respond_to do |format|
      if @card_transaction.update_attributes(params[:card_transaction])
        format.html { redirect_to(@card_transaction, :notice => 'CardTransaction was successfully updated.') }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @card_transaction.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /card_transactions/1
  # DELETE /card_transactions/1.xml
  def destroy
    @card_transaction = CardTransaction.find(params[:id])
    @card_transaction.void_refund

    respond_to do |format|
      format.html { redirect_to(card_transactions_url) }
      format.xml  { head :ok }
    end
  end
  
  private
  
  def error_resp(resp)
    message = ""
    case resp.class
    when Faraday::Response
      JSON.parse(resp).each {|key,val| message << " #{key}: #{val}"}
    when FalseClass
      message = 'processing error: '
      flash[:error] =  message
      error message
    else
      # communication failure details
      message = 'communication or configuration error'
      flash[:error] =  message
      error message 
    end
    message
  end

  def errors_in_transaction(trans)
    if trans.errors.empty?
      debug 'no errors'
      return false 
    else
      debug 'processing error'
      message = 'Processing error: '
      trans.errors.each{|attr,msg| message += "#{attr} - #{msg}\n" }
      flash[:error] =  message
      return true
    end
  end

  def handle_processing_error(trans)
    message = 'processing error: '
    trans.errors.each{|attr,msg| message += "#{attr} - #{msg} \n" }
    flash[:error] =  message
    error message
    @success = false
  end

  def handle_other_error(trans)
    # communication failure details
    message = ''
    trans.errors.each{|attr,msg| message += "#{attr} - #{msg}\n" }
    if message.empty?
      err = error_resp(resp.body)
      flash[:error] =  "communication error: #{err}"
      error "communication error: #{err}"
    else
      flash[:error] =  message
      error message 
    end
    @success = false
  end

end
