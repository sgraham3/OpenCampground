require 'test_helper'

class TaxrateTest < ActiveSupport::TestCase
  fixtures :taxrates

  def setup
    @sales = Taxrate.find 1
    @local = Taxrate.find 2
    @room = Taxrate.find 3
  end

  def test_default
    # make sure the defaults are correct
    assert @tax = Taxrate.new( :name => "test_tax")
    assert_equal false, @tax.is_percent
    assert_equal 0.0, @tax.percent
    assert_equal 0.0, @tax.amount
    assert_equal false, @tax.apl_month
    assert_equal false, @tax.apl_week
    # this will fail validation
    assert !@tax.save
  end

  def test_create
    assert @tax = Taxrate.new( :name => "test_tax", :is_percent => true, :percent => 3.5)
    assert @tax.is_percent
    assert_not_equal 0.0, @tax.percent
    assert_equal 0.0, @tax.amount
    assert_equal false, @tax.apl_month
    assert_equal false, @tax.apl_week
    # this will pass validation
    assert @tax.save
  end

  def test_delete
    assert @local.destroy
  end

  def test_update
  end

  def test_presense_of_name
    # create without name
    tax = Taxrate.new( :is_percent => true, :percent => 3.5)
    assert !tax.valid?
    assert tax.errors.invalid?(:name)
    # put on name
    tax.name = "any tax"
    # validate with name
    assert tax.valid?
  end

  def test_uniqueness_of_name
    # create with reused name
    tax = Taxrate.new( :name => 'room tax', :is_percent => true, :percent => 3.5)
    assert !tax.valid?
    assert tax.errors.invalid?(:name)
    # change the name
    tax.name = 'another tax'
    assert tax.valid?
  end
end
