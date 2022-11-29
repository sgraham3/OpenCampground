require 'test_helper'

class CamperTest < ActiveSupport::TestCase
  fixtures :campers

  def setup
    # use camper 1 for these tests
    @camper = Camper.find("1")
  end

  def test_create
    ####
    # check data in first camper
    ####
    assert_kind_of Camper, @camper
    assert_equal  0, @camper.lock_version
    assert_equal  1, @camper.id
    assert_equal  'Joe', @camper.first_name
    assert_equal  'Peterson', @camper.last_name
    assert_equal  '123 Rainbow Dr.', @camper.address
    assert_equal  'Livingston', @camper.city
    assert_equal  'TX', @camper.state
    assert_equal  '77399', @camper.mail_code
    assert_equal  nil, @camper.country
    assert_equal  'joe@earthlink.net', @camper.email
    assert_equal  '713 234-4576', @camper.phone
  end

  #####################################
  # make sure full_name returns correct
  # values
  #####################################
  def test_full_name
    assert_equal 'Joe Peterson', @camper.full_name
  end

  #####################################
  # check last name is required
  #####################################
  def test_presense_of_last_name
    camper = Camper.new
    # validate without last name
    assert !camper.valid?
    assert camper.errors.invalid?(:last_name)
    # put on last name
    camper.last_name = "anything"
    # validate with last name
    assert camper.valid?
  end

  def test_remote
    option = Option.first
    assert @camper.valid?
    @camper.update_attribute :remote, true
    option.update_attribute :require_email, true
    assert @camper.valid?
    @camper.update_attribute :email, "zzz"
    assert !@camper.valid?
    @camper.update_attribute :email, ""
    assert !@camper.valid?
    option.update_attribute :require_email, false
    option.update_attribute :require_phone, true
    assert @camper.valid?
    @camper.update_attribute :phone, ""
    assert !@camper.valid?
  end

  #####################################
  # make sure activity works
  #####################################
  def test_activity
    @camper.active
    # fetch camper again to make sure it changed
    @camper2 = Camper.find(1)
    assert_equal  Date.today, @camper2.activity
  end

  #####################################
  # test removal of non-printing char at front of name
  #####################################
  def test_remove_blanks
    @camper.update_attributes :last_name => ' Peterson'
    assert_equal 'Peterson', @camper.last_name
  end

end
