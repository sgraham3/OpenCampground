class Payment::RefundsController < ApplicationController
  # GET /payment_refunds/1/edit
  def edit
    @page_title = 'Update Refund'
    @payment = Payment.find(params[:id])
    if @payment.refundable
      debug 'payment is refundable'
      name = Integration.first.name
      if name.start_with?('CardKnox')
        debug 'using CkTransaction'
        @transaction = CkTransaction.find_by_payment_id!(@payment.id)
      elsif name.start_with?('CardConnect')
        debug 'using CardTransaction'
        @transaction = CardTransaction.find_by_payment_id!(@payment.id)
      else
        raise 'Unknown integration name'
      end
      @transaction.amount = Payment.total(@payment.reservation_id)
    else
      flash[:warning] = "payment not refundable"
      redirect_to payments_url # the list of payments
    end
    unless @transaction.retref
      flash[:error] = "Payment not refundable"
      redirect_to payments_url # the list of payments
    end
  rescue StandardError => e
    flash[:error] = e.to_s
    error e.to_s
    redirect_to payments_url
  end

  # PUT /payment_refunds/1
  # PUT /payment_refunds/1.xml
  # need transactions.id and .amount
  def update
    debug "refund is #{params[:transaction][:amount]}, id is #{params[:id]}"
    name = Integration.first.name
    if name.start_with?('CardKnox')
      debug 'using CkTransaction'
      orig = CkTransaction.find(params[:id])
    elsif name.start_with?('CardConnect')
      debug 'using CardTransaction'
      orig = CardTransaction.find(params[:id])
    else
      raise 'Unknown integration name'
    end
    debug 'orig loaded'
    trans = orig.clone
    debug 'orig cloned'
    # can't refund more than the original amount
    trans.amount = params[:transaction][:amount] if params[:transaction][:amount].to_f < trans.amount
    debug "refund amount is #{trans.amount}"
    trans.save
    debug 'trans saved'
    debug "transaction: #{trans.inspect}"
    do_refund(orig, trans)
    if trans['respstat'] == 'A' && trans.receiptData?
      redirect_to payment_receipt_url(trans.id)
    else
      redirect_to payments_url # the list of payments
    end
    # rescue StandardError => e
    # error e.to_s
    # redirect_to payments_url # the list of payments
  end

  private

  def do_refund(original, transaction)
    debug 'do_refund'
    if original.amount == transaction.amount
      debug "original #{original.amount} == transaction #{transaction.amount} doing void/refund"
      stat = transaction.void_refund
      debug "void_refund returned #{stat}"
    else
      # cannot do a partial void AFAIK
      debug "original #{original.amount} != transaction #{transaction.amount} doing refund only"
      debug transaction.inspect
      stat = transaction.refund
      debug "refund returned #{stat}"
      debug transaction.inspect
    end
    debug "status is #{stat}"
    if stat
      debug "respstat = #{transaction.respstat}, authcode = #{transaction.authcode}, amount = #{transaction.amount}"
      if transaction.respstat == 'A'
        debug "before: original amount is #{original.amount}, trans amount is #{transaction.amount}"
        transaction.amount = transaction.amount == 0.0 ? -original.amount : -transaction.amount
        debug "after:  original amount is #{original.amount}, trans amount is #{transaction.amount}"
        if transaction.authcode == 'REVERS'
          debug 'void'
          memo = "voided retref #{original.retref}"
          transaction.refundable = false
          flash[:notice] = "Credit card transaction for reservation #{original.reservation_id} voided"
          info "Credit card transaction for reservation #{original.reservation_id} voided"
        else
          # refund
          if -original.amount == transaction.amount
            memo = "full refund of retref #{original.retref}"
            debug "full refund: amount is #{transaction.amount}"
          else
            memo = "partial refund (#{number_2_currency(transaction.amount)}) of retref #{original.retref}"
            debug "partial refund: amount is #{transaction.amount}"
          end
          flash[:notice] = "Credit card transaction for reservation #{original.reservation_id} refunded"
          info "Credit card transaction for reservation #{original.reservation_id} refunded"
        end
        pmt = Payment.create(:reservation_id => transaction.reservation_id,
                             :credit_card_no => transaction.payment.credit_card_no,
                             :amount => transaction.amount,
                             :memo => memo,
                             :creditcard_id => transaction.payment.creditcard_id)
        payments = Payment.find_all_by_reservation_id transaction.reservation_id, :order => 'created_at'
        due = 0.0
        payments.each do |p|
          debug "payment = #{p.amount} due = #{due}"
          due += p.amount
        end
        debug "payments left = #{due}"
        payments[0].update_attributes :refundable => false if due <= 0.0
        res = Reservation.find(transaction.reservation_id)
        res.add_log(memo)
        # keep a record of the void/refund
        transaction.payment_id = pmt.id
        # not saved unless successful
        transaction.save
        # the refunded payment is now not refundable
        pmt.update_attributes :refundable => false
      else
        flash[:error] = "credit card transaction not refunded: #{transaction.resptext}(#{transaction.respcode})"
        error "credit card transaction not refunded: #{transaction.resptext}(#{transaction.respcode})"
      end
      debug "refund/void: #{transaction.inspect}"
    else
      debug "refund/void: #{transaction.inspect}"
      debug transaction.class.to_s
      if transaction.instance_of?(CkTransaction)
        debug 'error on cardknox transaction'
        flash[:error] = transaction.error
        error transaction.error
      else
        flash[:error] = "Error: #{transaction.resptext}"
        error transaction.resptext
      end
    end
  end
end
