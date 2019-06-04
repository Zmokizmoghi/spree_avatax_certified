class SpreeAvataxCertified::Request::GetTax < SpreeAvataxCertified::Request::Base
  def generate
    @request = {
      code: order.number,
      type: @doc_type ? @doc_type : 'SalesOrder',
      discount: order.all_adjustments.promotion.eligible.sum(:amount).abs.to_s,
      commit: @commit,
      addresses: address_lines,
    }.merge(base_tax_hash)

    @request
  end


end
