require 'test_helper'

class RigtypeTest < ActiveSupport::TestCase
  fixtures :rigtypes

  # create a record to compare to 
  def setup
    rig = Rigtype.new :name => 'validname'
    rig.save
  end

  def test_presense_of_name
    # create without name
    rig = Rigtype.new
    assert !rig.valid?
    assert rig.errors.invalid?(:name)
    # put on name
    rig.name = "anything"
    # validate with name
    assert rig.valid?
  end

  def test_uniqueness_of_name
    # create with reused name
    rig = Rigtype.new :name => 'validname'
    assert !rig.valid?
    assert rig.errors.invalid?(:name)
    # change the name
    rig.name = 'anothername'
    assert rig.valid?
  end
end
