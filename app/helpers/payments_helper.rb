module PaymentsHelper

  def confirm_text(id)
    ct = CardTransaction.find_by_payment_id(id)
    if ct
      I18n.t('general.ConfirmDestroy') + ' It will also void or refund the associated credit card transaction.'
    else
      I18n.t('general.ConfirmDestroy')
    end
  end

  def receipt(pmt)
    ct = CardTransaction.find_by_payment_id(pmt.id)
    if ct && ct.receiptData?
      "<td>#{link_to "Receipt", payment_receipt_path(ct.id)}</td>"
    else
      "<td>#{link_to "Receipt", payment_pmt_receipt_path(pmt.id)}</td>"
    end
  end

end
