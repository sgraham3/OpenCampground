class PaymentsController < ApplicationController
  before_filter :login_from_cookie
  before_filter :check_login
  before_filter :clear_session

  # GET /payments
  def index
    debug
    if params[:id]
      @page_title = "Payments for Reservation #{params[:id]}"
      @payments = Payment.paginate(:page => params[:page], :per_page => @option.disp_rows, :include => 'creditcard',
                                   :conditions => ["reservation_id = ?", params[:id]], :order => "pmt_date ASC")
      @id = params[:id]
    else
      @page_title = 'Payments by Reservation'
      @payments = Payment.paginate(:page => params[:page], :per_page => @option.disp_rows, :include => "creditcard",
                                   :order => "reservation_id desc, created_at")
    end
  end

  # GET /payments/1/edit
  def edit
    debug params[:id]
    @payment = Payment.find(params[:id].to_i)
    @page_title = "Edit Payment #{@payment.id} for Reservation #{@payment.reservation_id}"
  end

  # PUT /payments/1
  def update
    debug params[:id]
    @payment = Payment.find(params[:id].to_i)

    if @payment.update_attributes(params[:payment])
      flash[:notice] = 'Payment updated'
      Reservation.find(@payment.reservation_id).add_log("payment #{@payment.id} updated")
      redirect_to(payments_url)
    else
      flash[:error] = 'Payment update failed'
      render :action => "edit"
    end
  end

  # DELETE /payments/1
  def destroy
    debug params[:id]
    payment = Payment.find(params[:id].to_i)
    payment.destroy
    begin
      Reservation.find(payment.reservation_id).add_log("payment #{payment.id} record destroyed")
    rescue StandardError => e
      error e.to_s
    end
    redirect_to(payments_url)
  end
end
