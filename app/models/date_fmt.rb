class DateFmt 

  def self.formats
    return %w(default short long month)
  end

  def self.format_date(val = Date.today,opt = false)
    if opt
      I18n.l(val, :format => opt.to_sym)
    else
      I18n.l(val)
    end
  rescue
    I18n.l(val)
  end
end
