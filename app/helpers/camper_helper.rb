module CamperHelper

  def close_reason(res)
    arc = Archive.find_by_reservation_id(res)
    if arc
      return arc.close_reason
    else
      'closed'
    end
  end

  def manditory_label
    '<b>* ' + I18n.t('notice.Required') + '</b><br />'
  end
    
  def manditory(item, remote, option)
    if remote
      '*' if option.send(item)
    else
      '*' if option.send('l_' + item)
    end
  end

  def required(item, remote, option, extra = false)
    if remote
      if option.send(item)
	h = {:autocomplete => 'off',:required => true}
      else
	h = {:autocomplete => 'off'}
      end
    else
      if option.send('l_' + item)
	h = {:autocomplete => 'off',:required => true}
      else
	h = {:autocomplete => 'off'}
      end
    end
    # h.merge(extra) if extra
    return h
  end

  def next_action(camper, res_id)
    case session[:next_controller]
    when 'reservation'
      case session[:next_action]
      when 'update_camper', 'update_camper_id'
	# logger.debug 'reservation#update_camper'
	"<a href=\"/reservation/update_camper?camper_id=#{camper}&amp;reservation_id=#{res_id}\">#{I18n.t('general.Select')}</a>"

      when 'confirm_res'
	# logger.debug 'reservation#confirm_res'
	"<a href=\"/reservation/confirm_res?camper_id=#{camper}&amp;reservation_id=#{res_id}\">#{I18n.t('general.Select')}</a>"
      else
        # not complete
	act = session[:next_action] ? session[:next_action] : 'none'
	# logger.debug "reservation##{act}"
	link_to I18n.t('general.Select'), :controller => :reservation, :action => :find_by_campername, :camper_id => camper
      end
    when 'camper'
      # not complete
      act = session[:next_action] ? session[:next_action] : 'none'
      logger.debug "camper##{act}"
      link_to I18n.t('general.Show'), :controller => :camper, :action => :show, :camper_id => camper
    when 'group_res'
      logger.debug 'group_res'
      link_to I18n.t('general.Select'), :controller => :group_res, :action => :create, :camper_id => camper
    else
      act = session[:next_action] ? session[:next_action] : 'none'
      ctl = session[:next_controller] ? session[:next_controller] : 'none'
      logger.debug "#{ctl}##{act}"
      link_to I18n.t('general.Select'), :controller => :reservation, :action => :find_by_campername, :camper_id => camper
    end
  # rescue => err
    # error "fall through: #{err}"
  end
end
