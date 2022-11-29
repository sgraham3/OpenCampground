class Payment::PmtReceiptsController < ApplicationController
  # GET /payment_pmt_receipts/1
  def show
    @page_title = 'Payment Receipt'
    @payment = Payment.find(params[:id])
  rescue StandardError => e
    flash[:error] = e.to_s
    error e.to_s
    redirect_to payments_url
  end
end
