require 'digest/sha1'

class User < ActiveRecord::Base

  has_many :remember_logins, :dependent => :delete_all
  validates_presence_of     :name
  validates_uniqueness_of   :name
  attr_accessor             :password_confirmation
  validates_confirmation_of :password
  validate                  :password_non_blank?

  def before_destroy
    if admin
      count = User.find(:all, :conditions => ["admin = ?", true]).size 
      # ActiveRecord::Base.logger.debug "size = #{count}"
      count > 1
    else
      true
    end
  end

  def before_update
    if admin
      true
    elsif admin_was
      User.find(:all, :conditions => ["admin = ?", true]).size > 1
    else
      true
    end
  end

  def self.authenticate(name, password)
    user = self.find_by_name(name)
    if user
      expected_password = encrypted_password(password, user.salt)
      if user.hashed_password != expected_password
        user = nil
      end
    end
    user
  end

  def self.find_by_remember_token(token)
    rem = RememberLogin.find_by_token(token)
    rem.reset_token
    if rem.token_expires.past
      nil
    else
      rem.user
    end
  rescue
    nil
  end

  def self.authorized?(ctl, action, func = 'unk')
    ActiveRecord::Base.logger.debug "in authorized args are #{ctl} and #{action}"
    _user = self.current
    # everything is authorized if not using login
    return true if _user == nil
    ActiveRecord::Base.logger.debug "user is #{_user}"
    current = find(_user)
    ActiveRecord::Base.logger.debug "admin is #{current.admin?}"
    # everything is authorized if user is admin
    return true if current.admin?

    # now here is the rest
    option = Option.first
    case ctl
    when 'users'
      case action
      when 'edit'
	return true
      when 'update'
	return true
      else
        return false
      end
    when 'reservation'
      case action
      when 'purge'
	return false
      end
    when 'setup/index'
      return false
    when 'version'
      return false unless option.all_updates
    when 'archive'
      return false unless option.all_archives
    when 'extra_charges'
      return false unless option.all_manage_measured
    when 'payments'
      return false unless option.all_manage_payments
    when 'admin' # admin controller
      case action
      # when 'restart_passenger'
	# return false unless option.all_restart 
      when 'do_backup'
	return false unless option.all_backup
      when 'manage_logs'
	return false unless option.all_manage_logs
      when 'manage_backups', 'uploadFile', 'do_restore'
	return false unless option.all_manage_backup
      when 'do_delete', 'do_download'
	case func
	  when 'log'
	    return false unless option.all_manage_logs
	  when 'backup'
	    return false unless option.all_manage_backup
	  end
      when 'maintenance'
	return false unless option.all_backup ||
			    option.all_manage_backup ||
			    option.all_manage_logs ||
			    option.all_manage_payments ||
			    option.all_manage_measured
      end
    when 'report' # report controller
      case action
      when 'index'
	return false unless option.all_checkin_rpt ||
			    option.all_leave_rpt ||
			    option.all_arrival_rpt ||
			    option.all_departure_rpt ||
			    option.all_in_park_rpt ||
			    option.all_space_sum_rpt ||
			    option.all_occupancy_rpt ||
			    option.all_campers_rpt ||
			    option.all_transactions_rpt ||
			    option.all_payments_rpt ||
			    option.all_measured_rpt
      when 'checkins_today'
	return false unless option.all_checkin_rpt
      when 'checkouts_today'
	return false unless option.all_leave_rpt
      when 'sched_arr', 'sch_arr_report'
	return false unless option.all_arrival_rpt
      when 'sched_dep', 'sch_dep_report'
	return false unless option.all_departure_rpt
      when 'rig_count', 'rig_count_report'
	return false unless option.all_in_park_rpt
      when 'summary'
	return false unless option.all_space_sum_rpt
      when 'site_occ', 'site_occ_report', 'site_occ_csv'
	return false unless option.all_occupancy_rpt
      when 'campers', 'campers_csv'
	return false unless option.all_space_sum_rpt
      when 'transactions', 'transactions_report'
	return false unless option.all_transactions_rpt
      when 'payments', 'payments_report'
	return false unless option.all_payments_rpt
      when 'extras', 'extras_report'
	return false unless option.all_measured_rpt
      end
    end
    # ActiveRecord::Base.logger.debug 'authorized'
    true
  end

  def self.current
  # fetch the current user
    Thread.current[:user]
  end

  def self.current=(user)
  # set the current user
    Thread.current[:user] = user
  end

  # password is a virtual attribute
  def password
    @password
  end

  def password=(pwd)
    @password = pwd
    return if pwd.blank?
    create_new_salt
    self.hashed_password = User.encrypted_password(self.password, self.salt)
  end

  def remember_me
    remember = RememberLogin.create!(:user_id => self.id,
				     :token_expires => 2.weeks.from_now,
				     :token => Digest::SHA1.hexdigest("#{self.hashed_password}--#{2.weeks.from_now}"))
    return remember.token
  end

  def forget_me(token)
    RememberLogin.destroy_all(["token = ?", token])
  end

private

  def password_non_blank?
    errors.add(:password, "Missing password") if hashed_password.blank?
  end

  def self.encrypted_password(password, salt)
    string_to_hash = password + "slfiuoew" + salt
    Digest::SHA1.hexdigest(string_to_hash)
  end

  def create_new_salt
    self.salt = self.object_id.to_s + rand.to_s
  end

end
