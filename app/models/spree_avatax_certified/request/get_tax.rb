class SpreeAvataxCertified::Request::GetTax < SpreeAvataxCertified::Request::Base
  def generate
    @request = {
      code: order.number,
      type: @doc_type ? @doc_type : 'SalesOrder',
      date: doc_date,
      discount: order.all_adjustments.promotion.eligible.sum(:amount).abs.to_s,
      commit: @commit,
      addresses: address_lines,
      lines: sales_lines,
    }.merge(base_tax_hash)

    check_vat_id

    @request
  end

  protected

  def doc_date
    order.completed? ? order.completed_at.strftime('%F') : Date.today.strftime('%F')
  end
end
