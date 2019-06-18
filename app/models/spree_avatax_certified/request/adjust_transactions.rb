class SpreeAvataxCertified::Request::AdjustTransaction < SpreeAvataxCertified::Request::Base

  def generate
    @request = {
      adjustmentReason: 'Refund adjustment',
      newTransaction: options[:new_transaction]
    }
  end

end

