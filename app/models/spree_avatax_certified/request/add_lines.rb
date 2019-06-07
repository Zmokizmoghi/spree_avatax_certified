class SpreeAvataxCertified::Request::AddLines < SpreeAvataxCertified::Request::Base

  def initialize(id, order)
    @order = order
    @transaction_id = id
    @request = {}
  end


  def generate
    @request = {
      transactionCode: @transaction_id,
      lines: sales_lines,
      companyCode: company_code,
      addresses: address_lines,
    }
    @request
  end

  def sales_lines
    @sales_lines ||= SpreeAvataxCertified::Line.new(@order, 'string').shipment_lines_array
  end

  def company_code
    @company_code ||= Spree::Config.avatax_company_code
  end


end
