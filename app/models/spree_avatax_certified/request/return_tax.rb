class SpreeAvataxCertified::Request::ReturnTax < SpreeAvataxCertified::Request::Base

  def initialize(order, opts={})
    super
    @refund = opts[:refund]
  end

  def generate
    @request = {
      # companyCode in base hash
      # date in base hash
      # customerCode in base hash
      # email in base hash
      # lines in base hash
      lines: sales_lines,
      type: 'ReturnInvoice',
      companyCode: company_code,
      description: "Refund for a committed transaction #{order.number}",
      code: code,
      commit: @commit,
      purchaseOrderNo: order.number

    }

    @request.merge(base_tax_hash)
  end

  private

  def doc_date
    @refund.created_at.strftime('%F')
  end

  def code
    suffix = Rails.env.production? ? 'R' : 'S'
    number = order.number.gsub(/[^0-9]/, '')
    postfix = order.refunds.count > 1 ? "-#{order.refunds.count}" : ''

    ['C', suffix, number, postfix].compact.join
  end

end

