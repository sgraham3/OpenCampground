require 'test_helper'

class PriceTest < ActiveSupport::TestCase
  fixtures :prices

  # create a record to compare to 
  def setup
    price = Price.new :name => 'validname'
    price.save
  end

  def test_presense_of_name
    # create without name
    price = Price.new
    assert !price.valid?
    assert price.errors.invalid?(:name)
    # put on name
    price.name = "anything"
    # validate with name
    assert price.valid?
  end

  def test_uniqueness_of_name
    # create with reused name
    price = Price.new :name => 'validname'
    assert !price.valid?
    assert price.errors.invalid?(:name)
    # change the name
    price.name = 'anothername'
    assert price.valid?
  end
end
