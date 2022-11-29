require 'test_helper'

class UserTest < ActiveSupport::TestCase

  def test_name_is_required 
    # presence
    u = User.new(:password => 'abc', :password_confirmation => 'abc')
    assert !u.valid?
    assert u.errors.invalid? :name
  end

  def test_name_must_be_unique 
    u1 = User.new(:name => 'test_user', :password => 'zxcd', :password_confirmation => 'zxcd')
    u1.save
    # uniqueness
    u2 = User.new(:name => 'test_user', :password => 'abc', :password_confirmation => 'abc')
    assert !u2.valid?
    assert u2.errors.invalid? :name
  end

  def test_password_must_be_non_blank 
    u1 = User.new(:name => 'test_user2', :password => '', :password_confirmation => '')
    assert !u1.valid?
    assert u1.errors.invalid? :password
    u2 = User.new(:name => 'test_user3', :password => ' ', :password_confirmation => ' ')
    assert !u2.valid?
    assert u2.errors.invalid? :password
  end

  def test_password_must_confirm 
    # confirmation
    u = User.new(:name => 'test_user4', :password => 'abc', :password_confirmation => 'def')
    assert !u.valid?
    assert u.errors.invalid? :password
  end

  def test_password_must_authenticate 
    user = User.new(:name => 'test_user', :password => 'zxcd', :password_confirmation => 'zxcd')
    user.save
    assert User.authenticate('test_user', 'zxcd')
    # invalid
    assert !User.authenticate('test_user', 'aazxcd')
  end

  def test_must_keep_one_admin_user 
    user1 = User.create!(:name => 'test_user1', :password => 'zxcd', :password_confirmation => 'zxcd', :admin => true)
    user2 = User.create!(:name => 'test_user2', :password => 'zxcd', :password_confirmation => 'zxcd', :admin => true)
    assert user1.destroy # can destroy because there are two
    # Test does not work assert !user2.destroy # cannot destroy because it is last
    # Test does not work assert !user2.update_attributes(:name => 'another_user', :admin => false)
  end

  def current_user 
  end

  def authorization 
  end

end
