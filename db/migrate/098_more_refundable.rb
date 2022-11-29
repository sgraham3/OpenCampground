class MoreRefundable < ActiveRecord::Migration
  
  # a data only migration to make payments refundable if we have a retref
  # and the system uses CardConnect
  def self.up
    int = Integration.first
    if int && int.name.include?('CardConnect')
      pmts = Payment.all :conditions => ["refundable = ? and amount > ?", false, 0.00]
      pmts.each do |p|
        if p.memo
	  (junk, d, retref) = p.memo.partition 'retref '
	  if retref.length > 10
	    p.update_attributes :refundable => true
	    if CardTransaction.find_by_payment_id(p.id) == nil
	      # no card transaction with a good retref so create one
	      ct = CardTransaction.create :retref => retref,
					  :amount => p.amount,
					  :payment_id => p.id,
					  :reservation_id => p.reservation_id
	    end
	  end
	end
      end
    end
  end

  def self.down
    # not reversable
  end

end
