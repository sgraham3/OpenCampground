module Setup::SitetypeHelper
  def sitetype_taxrates
    # @sitetype and @taxes are available  
    debug "sitetype #{@sitetype.id} currently has these taxrates #{@sitetype.taxrate_ids.inspect}"
    ret_str = ''
    @taxes.each do |t|
      debug t.name
      ret_str << t.name + ': '
      if @sitetype.taxrates.exists?(t)
        # taxrate t currently applies to the sitetype
        debug "taxrate #{t.id} currently applies to sitetype #{@sitetype.id}"
        ret_str << "<input name=\"#{t.name}\" type=\"hidden\" value=\"0\" /><input checked=\"checked\" id=\"#{t.name}\" name=\"#{t.name}\" type=\"checkbox\" value=\"1\" \/>  "
      else
        debug "taxrate #{t.id} currently does not apply to sitetype #{@sitetype.id}"
        ret_str << "<input name=\"#{t.name}\" type=\"hidden\" value=\"0\" /><input id=\"#{t.name}\" name=\"#{t.name}\" type=\"checkbox\" value=\"1\" \/>  "
      end
    end
    return ret_str
  end

end
