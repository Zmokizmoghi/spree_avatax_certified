class SpreeAvataxCertified::Request::ReturnTax < SpreeAvataxCertified::Request::Base

  def initialize(order, opts={})
    super
    @refund = opts[:refund]
  end

  def generate
    @request = {
      refundTransactionCode: "CR#{order.number.gsub(/[^0-9]/, '')}",
      refundDate: Date.today.strftime('%F'),
      refundType: 'Full',
      referenceCode: "Refund for a committed transaction #{order.number}"
    }

    @request
  end

  protected

  def sales_lines
    @sales_lines ||= SpreeAvataxCertified::Line.new(order, @doc_type, @refund).lines
  end
end
