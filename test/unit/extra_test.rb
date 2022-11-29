require 'test_helper'

class ExtraTest < ActiveSupport::TestCase
  fixtures :extras

  # create a record to compare to 
  def setup
    ext = Extra.new :name => 'validname'
    ext.save
  end

  def test_presense_of_name
    # create without name
    ext = Extra.new
    assert !ext.valid?
    assert ext.errors.invalid?(:name)
    # put on name
    ext.name = "anything"
    # validate with name
    assert ext.valid?
  end

  def test_uniqueness_of_name
    # create with reused name
    ext = Extra.new :name => 'validname'
    assert !ext.valid?
    assert ext.errors.invalid?(:name)
    # change the name
    ext.name = 'anothername'
    assert ext.valid?
  end
end
