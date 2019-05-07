class SpreeAvataxCertified::Request::CancelTax < SpreeAvataxCertified::Request::Base
  def generate
    @request = {
      code: 'DocVoided'
    }
  end
end
