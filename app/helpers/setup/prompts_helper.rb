module Setup::PromptsHelper
  def display_name(name)
    # debug "display_name #{name}"
    case name
    when 'CardConnect-payment'
      'CardConnect payment'
    when 'CardConnect-a-payment'
      'CardConnect optional payment'
    when 'CardKnox-payment'
      'CardKnox payment'
    when 'CardKnox-a-payment'
      'CardKnox optional payment'
    when 'PayPal-payment'
      'PayPal payment'
    when 'PayPal-a-payment'
      'PayPal optional payment'
    when 'confirmation'
      'Reservation Confirmation'
    when 'find_space'
      'Select Space'
    when 'index'
      'Initial Page'
    when 'show'
      'Review'
    when 'wait_for_confirm'
      'Wait for PayPal'
    when 'find_remote'
      'Camper Information'
    else
      name
    end
  end
  
  def display?(display)
    if @integration.name.start_with?('CardConnect')
      # debug 'processing CardConnect'
      if display == 'CardConnect-payment'
        # debug @option.require_gateway?.to_s
        return @option.require_gateway?
      elsif display == 'CardConnect-a-payment'
	# debug @option.allow_gateway?.to_s
	return @option.allow_gateway?
      elsif display == 'wait_for_confirm'
	# debug 'false'
        return false
      elsif display == 'PayPal-payment'
	# debug 'false'
	return false
      elsif display == 'PayPal-a-payment'
	# debug 'false'
        return false
      elsif display == 'CardKnox-payment'
	# debug 'false'
        return false
      elsif display == 'CardKnox-a-payment'
	# debug 'false'
        return false
      else
	# debug 'true'
        return true
      end
    elsif @integration.name.start_with?('CardKnox')
      # debug 'processing CardKnox'
      if display == 'CardKnox-payment'
        # debug @option.require_gateway?.to_s
        return @option.require_gateway?
      elsif display == 'CardKnox-a-payment'
	# debug @option.allow_gateway?.to_s
	return @option.allow_gateway?
      elsif display == 'CardConnect-payment'
	# debug 'false'
        return false
      elsif display == 'CardConnect-a-payment'
	# debug 'false'
        return false
      elsif display == 'PayPal-payment'
	# debug 'false'
	return false
      elsif display == 'PayPal-a-payment'
	# debug 'false'
        return false
      elsif display == 'wait_for_confirm'
	# debug 'false'
        return false
      else
	# debug 'true'
        return true
      end
    elsif @integration.name.start_with?('PayPal')
      # debug 'processing PayPal'
      if display == 'PayPal-payment'
        # debug @option.require_gateway?.to_s
        return @option.require_gateway?
      elsif display == 'PayPal-a-payment'
	# debug @option.allow_gateway?.to_s
	return @option.allow_gateway?
      elsif display == 'wait_for_confirm'
	# debug 'true'
	return true
      elsif display == 'CardConnect-payment'
	# debug 'false'
        return false
      elsif display == 'CardConnect-a-payment'
	# debug 'false'
        return false
      elsif display == 'CardKnox-payment'
	# debug 'false'
        return false
      elsif display == 'CardKnox-a-payment'
	# debug 'false'
        return false
      else
	# debug 'true'
        return true
      end
    elsif @integration.name == 'None'
      debug display
      if display == 'PayPal-payment'
	return false
      elsif display == 'PayPal-a-payment'
        return false
      elsif display == 'CardConnect-payment'
        return false
      elsif display == 'CardConnect-a-payment'
        return false
      elsif display == 'wait_for_confirm'
        return false
      elsif display == 'CardKnox-payment'
	# debug 'false'
        return false
      elsif display == 'CardKnox-a-payment'
	# debug 'false'
        return false
      else
        return true
      end
    end
  end
end
