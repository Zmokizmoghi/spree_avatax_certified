class SpreeAvataxCertified::Request::AdjustTransaction < SpreeAvataxCertified::Request::Base
  def initialize(order, opts={})
    super
    @new_transaction = opts[:new_transaction]
  end

  def generate
    @request = {
      adjustmentReason: 'Other',
      adjustmentDescription: 'Refund Adjustment',
      newTransaction: new_transaction
    }
  end

end

