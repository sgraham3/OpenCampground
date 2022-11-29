module Setup::ExtraHelper
  def extra_taxrates
    # @extra and @taxes are available  
    debug "extra #{@extra.id} currently has these taxrates #{@extra.taxrate_ids.inspect}"
    ret_str = ''
    @taxes.each do |t|
      debug t.name
      ret_str << t.name + ': '
      if @extra.taxrates.exists?(t) 
        # taxrate t currently applies to the extra
        debug "taxrate #{t.id} currently applies to extra #{@extra.id}"
	ret_str << check_box('tax', t.name, :checked => "checked")
      else
        debug "taxrate #{t.id} currently does not apply to extra #{@extra.id}"
	ret_str << check_box('tax', t.name)
      end
    end
    return ret_str
  end
end
