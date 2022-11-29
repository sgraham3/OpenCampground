module Report::OccSitesHelper
  def header_occ(hdr)
    str = ""
    hdr.each do |h|
      str << '<td align="center">'
      str << h
      str << '</td>'
    end
    return str
  end

  def total_occ(occ)
    total = 0
    occ.each {|o| total += o}
    return total
  end
end
