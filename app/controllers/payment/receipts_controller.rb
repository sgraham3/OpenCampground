class Payment::ReceiptsController < ApplicationController
  require 'yaml'

  # GET /payment_receipts/1
  # GET /payment_receipts/1.xml
  def show
    # @receipt is just a hash not an ar object
    @card_transaction = CardTransaction.find(params[:id])
    # debug @card_transaction.inspect
    # debug @card_transaction.emvTagData.inspect
    if @card_transaction.emvTagData?
      @emv = JSON.parse @card_transaction.emvTagData
      debug "@emv: #{@emv.inspect}"
    else
      @emv = false
    end
    if @card_transaction.receiptData?
      # debug @card_transaction.receiptData.inspect
      begin
	@receipt = JSON.load @card_transaction.receiptData
	debug 'ReceiptController#show receiptData parsed as JSON'
      rescue
	@receipt = YAML.load @card_transaction.receiptData
	debug 'ReceiptController#show receiptData parsed as YAML'
      end
      debug "@receipt: #{@receipt.inspect}"
    else
      @receipt = {}
    end
    @merchid = Integration.first.cc_merchant_id.gsub(/.(?=.{4})/,'x')
    if @card_transaction.account.empty?
      @card = 'invalid'
    else
      @card = @card_transaction.account.gsub(/.(?=.{4})/,'x')
    end

    respond_to do |format|
      format.html { render :layout => 'receipt' } # show.html.erb
      format.xml  { render :xml => @receipt }
    end
  end

end
