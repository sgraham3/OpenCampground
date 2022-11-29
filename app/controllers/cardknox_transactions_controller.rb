class CardknoxTransactionsController < ApplicationController
  # GET /cardknox_transactions
  # GET /cardknox_transactions.xml
  require 'pp'

  def index
    @ck_transactions = CkTransaction.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @ck_transactions }
    end
  end

  # GET /cardknox_transactions/1
  # GET /cardknox_transactions/1.xml
  def show
    @ck_transaction = CkTransaction.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @ck_transaction }
    end
  end

  # GET /cardknox_transactions/new
  # GET /cardknox_transactions/new.xml
  def new
    @page_title = 'Pay with CardKnox'
    @integration = Integration.first
    @reservation = Reservation.find params[:ck_transaction][:reservation_id]
    debug 'create a card transaction'
    @ck_transaction = CkTransaction.new(params[:ck_transaction].merge(:amount => @reservation.due.round(2)))
  end

  # GET /cardknox_transactions/1/edit
  def edit
    @ck_transaction = CkTransaction.find(params[:id])
  end

  # POST /bbpos_cardknox_transactions
  def bbpos
    # response from bbpos transaction
    new_params = params.slice(:xExp, :xInvoice, :xAuthAmount, :xCurrency, :xResult, :xStatus,
                              :xError, :xRefNum, :xToken, :xBatch, :xMaskedCardNumber, :xCardType)
    @ck_transaction = CkTransaction.create!(new_params.merge({ :process_mode => CardTransaction::BbPos }))
    if @ck_transaction.result == 'A'
      # no error
      debug "purchase completed status = #{@ck_transaction.status}"
      info 'transaction approved'
    else
      @ck_transaction.update_attributes :amount => 0
      flash[:error] = "Error: #{@ck_transaction.error}"
      error @ck_transaction.error
      render new_cardknox_transaction_path, :layout => true
    end
    # record payment using response data
    creditcard_id = Creditcard.find_or_create_by_name(@ck_transaction.card_brand).id
    p = Payment.create(:reservation_id => @ck_transaction.reservation_id,
                       :credit_card_no => @ck_transaction.masked_card_num,
                       :creditcard_id => creditcard_id,
                       :amount => @ck_transaction.amount,
                       :cc_expire => params[:xExp],
                       :refundable => true,
                       :memo => "BBPOS: retref #{@ck_transaction.retref}")
    flash[:notice] = "Transaction approved"
    @ck_transaction.update_attributes :payment_id => p.id
    Reservation.find(@ck_transaction.reservation_id).add_log("paid with CardKnox")
    redirect_to :controller => :reservation, :action => :show,
                :reservation_id => @ck_transaction.reservation_id and return
  rescue ActiveRecord::RecordNotFound
    flash[:error] = "Reservation idle over 30 minutes.  Starting over"
    redirect_to :controller => :remote, :action => :index and return if @remote

    redirect_to :controller => :reservation, :action => :index and return
  rescue StandardError => e
    debug "Transaction not approved: #{e}"
    flash[:error] = "Transaction not approved: #{e}"
    render new_cardknox_transaction_path, :layout => true
  end

  # POST /cardknox_transactions
  # POST /cardknox_transactions.xml
  def create
    begin
      res = Reservation.find(params[:ck_transaction][:reservation_id])
    rescue ActiveRecord::RecordNotFound
      flash[:error] = "Reservation idle over 30 minutes.  Starting over"
      redirect_to :controller => :remote, :action => :index and return if @remote

      redirect_to :controller => :reservation, :action => :index and return
    end
    trans = params[:ck_transaction]
    amount = currency_2_number(params[:ck_transaction][:amount])
    dt = Date.new trans["expiry(1i)"].to_i, trans["expiry(2i)"].to_i, trans["expiry(3i)"].to_i
    process_mode = params[:ck_transaction][:process_mode]
    debug 'creating transaction'
    @ck_transaction = CkTransaction.create({ :action => 'purchase',
                                             :amount => amount,
                                             :process_mode => process_mode,
                                             :xCardNum => params[:xCardNum],
                                             :xCVV => params[:xCVV],
                                             :month => dt.month,
                                             :year => dt.year,
                                             :reservation_id => res.id })
    debug 'starting purchase'
    result = @ck_transaction.purchase
    if result.success?
      # no error
      debug "purchase completed status = #{result.success?}"
      info 'transaction approved'
    else
      @ck_transaction.update_attributes :amount => 0
      flash[:error] = "Error: #{result.params['error']}"
      error result.params["error"]
      if @ck_transaction.process_mode == CardTransaction::TokenRemote
        redirect_to :controller => :remote, :action => :payment,
                  :reservation_id => @ck_transaction.reservation_id and return
      end

      redirect_to :controller => :reservation, :action => :show,
                  :reservation_id => @ck_transaction.reservation_id and return
    end
    Reservation.find(@ck_transaction.reservation_id).add_log("paid with CardKnox")
    flash[:notice] = "Transaction approved"
    # record payment using response data
    creditcard_id = Creditcard.find_or_create_by_name(@ck_transaction.card_brand).id
    p = Payment.create(:reservation_id => @ck_transaction.reservation_id,
                       :credit_card_no => @ck_transaction.masked_card_num,
                       :creditcard_id => creditcard_id,
                       :amount => @ck_transaction.amount,
                       :cc_expire => @ck_transaction.expiry,
                       :refundable => true,
                       :memo => "Tokenized: retref #{@ck_transaction.retref}")
    @ck_transaction.update_attributes :payment_id => p.id
    redirect_to :controller => :remote, :action => :confirmation,
		:reservation_id => @ck_transaction.reservation_id and return if @ck_transaction.process_mode == CardTransaction::TokenRemote

    redirect_to :controller => :reservation, :action => :show,
                :reservation_id => @ck_transaction.reservation_id and return
  rescue StandardError => e
    debug "Transaction not approved: #{e}"
    flash[:error] = "Transaction not approved: #{e}"
    if process_mode == CardTransaction::TokenRemote
        redirect_to :controller => :remote, :action => :payment and return
    else
      render new_cardknox_transaction_path, :layout => true
    end
  end

  # PUT /cardknox_transactions/1
  # PUT /cardknox_transactions/1.xml
  def update
    @ck_transaction = CkTransaction.find(params[:id])
    respond_to do |format|
      if @ck_transaction.update_attributes(params[:ck_transaction])
        format.html do
          redirect_to(@ck_transaction, :notice => 'CkTransaction was successfully updated.')
        end
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @ck_transaction.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /cardknox_transactions/1
  # DELETE /cardknox_transactions/1.xml
  def destroy
    @ck_transaction = CkTransaction.find(params[:id])
    @ck_transaction.void_refund

    respond_to do |format|
      format.html { redirect_to(ck_transactions_url) }
      format.xml  { head :ok }
    end
  end
end
