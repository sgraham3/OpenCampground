module Report::CardTransactionsHelper
  def get_res(id)
    option = Option.first
    res = Reservation.find id
  rescue
    # a hash for required entries
    c = Camper.find_by_last_name 'unknown'
    unless c
      opts = {}
      opts [:last_name] = 'unknown'  if option.l_require_first?
      opts [:first_name] = 'unknown' if option.l_require_first?
      opts [:address] = 'unknown'    if option.l_require_addr?
      opts [:city] = 'unknown'       if option.l_require_city?
      opts [:state] = 'unknown'      if option.l_require_state?
      opts [:mail_code] = 'unknown'  if option.l_require_mailcode?
      opts [:phone] = 'unknown'      if option.l_require_phone?
      opts [:email] = 'un@known'     if option.l_require_email?
      opts [:idnumber] = '0'         if option.l_require_id?
      opts [:country] = Country.find_or_create_by_name('unknown').id if option.l_require_country?
      c = Camper.create opts
    end
    res = Reservation.new :camper_id => c
  end
end
