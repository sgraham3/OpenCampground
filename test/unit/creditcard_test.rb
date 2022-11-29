require 'test_helper'

class CreditcardTest < ActiveSupport::TestCase
  fixtures :creditcards

  # create a record to compare to 
  def setup
    c = Creditcard.new :name => 'validname'
    c.save
  end

  def test_presense_of_name
    # create without name
    cc = Creditcard.new
    assert !cc.valid?
    assert cc.errors.invalid?(:name)
    # put on name
    cc.name = "anything"
    # validate with name
    assert cc.valid?
  end

  def test_uniqueness_of_name
    # create with reused name
    cc = Creditcard.new :name => 'validname'
    assert !cc.valid?
    assert cc.errors.invalid?(:name)
    # change the name
    cc.name = 'anothername'
    assert cc.valid?
  end

  def test_card_number_validation
    # numbers that should be valid
    assert  Creditcard.valid_credit_card?('12345673847')
    assert  Creditcard.valid_credit_card?('49927398716')
    # number that should not be valid because we want a string
    assert !Creditcard.valid_credit_card?(12345678947)
    # number that should not be valid
    assert !Creditcard.valid_credit_card?('12345678947')
    assert !Creditcard.valid_credit_card?('48727398716')
  end

  def test_card_expiration
    # expiration date in the past.  Card expired
    c = Creditcard.new :name => 'validname', :validate_expiration => true
    assert  c.card_expired?(Date.today - 1.month )
    # expiration date in the future or today.  Card not expired
    assert !c.card_expired?(Date.today )
    # expiration date in the future.  Card not expired
    assert !c.card_expired?(Date.today + 1.month )
  end
end
