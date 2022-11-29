require 'test_helper'

class PaymentTest < ActiveSupport::TestCase
  def test_taxes
    r = Reservation.create! :total => 105.0, :tax_amount => 5.0, :startdate => Date.today, :enddate => Date.today + 1
    p = Payment.new :reservation_id => r.id, :amount => 105.0
    net, tax = p.taxes
    assert net.round == 100.0
    assert tax.round == 5.0
    # make it a little harder
    p.amount = 44.1
    net, tax = p.taxes
    assert_equal(net.round(2), 42.1)
    assert_equal(tax.round(2), 2.0)
  end
end
