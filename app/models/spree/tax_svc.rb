require 'json'
require 'net/http'
require 'addressable/uri'
require 'base64'
require 'rest-client'
require 'logging'
require 'avatax'

# Avatax tax calculation API calls
class TaxSvc

  def refund_tax(code, request_hash)
    log(__method__, request_hash)
    RestClient.log = logger.logger

    response = client.create_transaction(request_hash)

    handle_response(response)
  end

  def adjust_tax(transaction_code, request_hash)
    log(__method__, request_hash)
    RestClient.log = logger.logger

    response = client.adjust_transaction(company_code, transaction_code, request_hash)

    handle_response(response)
  end

  def get_tax(request_hash)
    log(__method__, request_hash)
    RestClient.log = logger.logger

    response = client.create_transaction(request_hash)

    handle_response(response)
  end

  def update_tax(request_hash)
    log(__method__, request_hash)
    RestClient.log = logger.logger

    response = client.add_lines(request_hash)

    handle_response(response)
  end

  def get_translactions(company_code, request_hash)
    log(__method__, request_hash)
    RestClient.log = logger.logger

    response = client.list_transactions_by_company(company_code, request_hash)

    handle_response(response)
  end

  def cancel_tax(request_hash, transaction)
    log(__method__, request_hash)
    RestClient.log = logger.logger

    response = client.void_transaction(company_code, transaction.order.number, request_hash)

    handle_response(response)
  end

  protected

  def handle_response(response)
    begin
      if response.keys.include?('error')
        Raven.capture_message("Avatax Error: Request failed with #{response}")

        logger.debug(response)
      end
    rescue => e
      Raven.capture_message("Avatax Error: Request failed with #{e.message}"
         user: { avatax_response: response } )
      logger.error(e.message)
    end

    log(__method__, response)

    response
  end

  def logger
    @logger ||= SpreeAvataxCertified::AvataxLog.new('TaxSvc class', 'Call to tax service')
  end

  private

  def company_code
    @company_code ||= Spree::Config.avatax_company_code
  end

  def tax_calculation_enabled?
    Spree::Config.avatax_tax_calculation
  end

  def client
    @client ||= AvaTax::Client.new(
      logger: Spree::Config.avatax_log,
      endpoint: Spree::Config.avatax_endpoint,
      username: Spree::Config.avatax_api_username,
      password: Spree::Config.avatax_api_password
    )
  end

  def log(method, request_hash = nil)
    return if request_hash.nil?
    logger.debug(request_hash, "#{method.to_s} request hash")
  end
end
