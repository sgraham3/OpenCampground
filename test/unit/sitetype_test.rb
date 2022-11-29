require 'test_helper'

class SitetypeTest < ActiveSupport::TestCase
  fixtures :sitetypes

  # create a record to compare to 
  def setup
    site = Sitetype.new :name => 'validname'
    site.save
  end

  def test_presense_of_name
    # create without name
    site = Sitetype.new
    assert !site.valid?
    assert site.errors.invalid?(:name)
    # put on name
    site.name = "anything"
    # validate with name
    assert site.valid?
  end

  def test_uniqueness_of_name
    # create with reused name
    site = Sitetype.new :name => 'validname'
    assert !site.valid?
    assert site.errors.invalid?(:name)
    # change the name
    site.name = 'anothername'
    assert site.valid?
  end
end
