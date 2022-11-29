module Report::DuesHelper
  def payment(res)
    _pmt = Payment.total(res.id)
    if @option.use_override && (res.override_total > 0.0)
      _total = res.override_total
    else
      _total = res.total + res.tax_amount
    end
    _due = _total - _pmt
    pmt = number_2_currency(_pmt)
    due = number_2_currency(_due)
    total = number_2_currency(_total)
    return pmt, due, total
  end
end
