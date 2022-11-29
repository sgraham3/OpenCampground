class Option < ActiveRecord::Base
  belongs_to :date_fmt
  validate :valid_phones?, :valid_licenses?, :valid_deposit?, :valid_auto_checkin?
  before_update :check_integrations, :if => :use_remote_reservations_changed?

  def use_find_by_id?
    use_id? && find_by_id? 
  end

  def pay?
    require_gateway? || allow_gateway?
  end

  def use_park_closed?
    if closed_start == closed_end
      return false
    else
      return use_closed?
    end
  end

private
  def valid_phones?
    if defined? no_phones 
      if (no_phones > 2) || (no_phones < 0)
	errors.add :no_phones, "value out of range"
      end
      if no_phones == 0
        errors.add :l_require_phone, ": phone required but number of phones is none" if l_require_phone?
        errors.add :require_phone, ": phone required on remote but number of phones is none" if use_remote_reservations? && require_phone?
      end
    end
  end
  def valid_licenses?
    if defined? no_vehicles 
      if (no_vehicles > 2) || (no_vehicles < 0)
	errors.add :no_vehicles, "value out of range"
      end
    end
  end
  def valid_deposit?
    if deposit_type < Remote::Full_charge || deposit_type > Remote::Days
      errors.add :deposit_type, "value out of range"
    end
  end
  def valid_auto_checkin?
    if auto_checkin_remote? and !remote_auto_accept?
      errors.add :remote_auto_checkin, "can only be used if remote auto accept is selected"
    end
  end
  def check_integrations
    # when we have changed the use of remote reservations
    # if we only had remote or none previously change to none
    # if we had remote and office change to office
    # otherwise no changes
    # ActiveRecord::Base.logger.debug 'check_integrations'
    int = Integration.first
    unless use_remote_reservations?
      # ActiveRecord::Base.logger.debug 'not using remote reservations'
      # not using remote reservations
      case int.name
      when 'None', 'PayPal_o', 'CardConnect_o'
	# ActiveRecord::Base.logger.debug "was #{int.name} no changes"
	# no changes
      when 'PayPal_r', 'CardConnect_r'
	# ActiveRecord::Base.logger.debug "was #{int.name} change to None"
	int.update_attributes :name => 'None'
      when 'CardConnect'
	# ActiveRecord::Base.logger.debug "was #{int.name} change to CardConnect_o"
	int.update_attributes :name => 'CardConnect_o'
      when 'PayPal'
	# ActiveRecord::Base.logger.debug "was #{int.name} change to CardConnect_o"
	int.update_attributes :name => 'PayPal_o'
      end
    end
  end
end
