class PaypalTransaction < ActiveRecord::Base
  include ActiveMerchant::Billing::Integrations
  include ActionController::UrlWriter
  include MyLib
  require 'cryptoOC'
  require 'openssl'
  belongs_to :reservation
  belongs_to :payment

  def handle(request, params)
    option = Option.first
    notify = Paypal::Notification.new(request.raw_post)
    if notify.acknowledge
      # Status of transaction. List of possible values:
      #   Canceled-Reversal
      #   Completed
      #   Denied
      #   Expired
      #   Failed
      #   In-Progress
      #   Partially_Refunded
      #   Pending
      #   Processed
      #   Refunded
      #   Reversed
      #   Voided
      case notify.status
      when "Completed","Refunded","Partially_Refunded"
	begin
	  err_msg = 'Could not find reservation '
	  reservation = Reservation.find(reservation_id)
	  err_msg = 'Could not update reservation '
	  reservation.confirm = true # if you paid it should be confirmed
	  reservation.gateway_transaction = params[:txn_id]
	  amount = 0.0
	  if params[:mc_gross]
	    amount = params[:mc_gross]
	  elsif params[:payment_gross]
	    amount = params[:payment_gross]
	  end
	  reservation.deposit = amount if params[:custom] && params[:custom].include?('Deposit')
	  reservation.save!
	  memo = ''
	  memo += "fee: #{params[:mc_fee]} " if params[:mc_fee]
	  if notify.status == "Refunded" || notify.status == "Partially_Refunded"
	    memo += notify.status
	  elsif params[:item_name]
	    memo += params[:item_name]
	  elsif params[:item_name1]
	    memo += params[:item_name1]
	  end
	  card = Creditcard.find_or_create_by_name 'PayPal'
	  memo += " #{params[:custom]}" if params[:custom] 
	  if reservation
	    Payment.create!(:reservation_id => reservation.id,
			    :creditcard_id => card.id,
			    :amount => amount,
			    :memo => memo)
	    ActiveRecord::Base.logger.info "Payment created for reservation #{reservation.id} (#{notify.status})"
	  else
	    ActiveRecord::Base.logger.info "Payment not created for reservation #{reservation.id} (#{notify.status})"
	  end
	  return true
	rescue => err
	  ActiveRecord::Base.logger.error 'Error: ' + err_msg + err.to_s
	end
      else
	# status not currently handled
	ActiveRecord::Base.logger.error "transaction #{notify.transaction_id.to_s} not handled: #{notify.status}"
      end
    else # transaction not acknowledged.....
      ActiveRecord::Base.logger.error "transaction #{notify.transaction_id.to_s} not acknowledged"
    end
    return false
  end

  def fetch_decrypted(wfc, ipn)
    option = Option.first
    int = Integration.first
    return false if(int.pp_business == nil || int.pp_cert_id == nil)
    res = Reservation.find self.reservation_id
    # cert_id is the certificate we see in paypal when we upload our own certificates
    # cmd _xclick need for buttons
    # item name is what the user will see at the paypal page
    # custom and invoice are passthrough vars which we will get back with the asynchronous
    # notification
    # no_note and no_shipping means the client wont see these extra fields on the paypal payment
    # page
    # return is the url the user will be redirected to by paypal when the transaction is completed.
    item_name = "Reservation for space #{res.space.name} from #{res.startdate} to #{res.enddate}"
    deposit = res.deposit_amount
    decrypted = {
      "business" => int.pp_business,
      "cmd" => "_xclick",
      "return" => wfc,
      "notify_url" => ipn,
      "invoice" => reservation_id.to_s,
      "cert_id" => int.pp_cert_id,
      "item_name" => item_name,
      "item_number" => "1",
      "custom" => deposit['custom'],
      "amount" => sprintf("%02f", deposit['amount']),
      "tax" => sprintf("%02f", deposit['tax']),
      "currency_code" => int.pp_currency_code,
      "country" => int.pp_country,
      "no_note" => "1",
      "no_shipping" => "1"
    }
    # discount is included in the amount
    # decrypted[:discount_amount] = disc if disc > 0.0
    ActiveRecord::Base.logger.debug decrypted.inspect
    CryptoOC::Button.from_hash(decrypted).get_encrypted_text
  end

end
