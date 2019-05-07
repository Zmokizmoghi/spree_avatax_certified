require 'json'
require 'net/http'
require 'base64'

module SpreeAvataxCertified
  class Address
    attr_reader :order, :addresses

    def initialize(order)
      @order = order
      @ship_address = order.ship_address
      @origin_address = JSON.parse(Spree::Config.avatax_origin)
      @addresses = {}

      build_addresses
    end

    def build_addresses
      origin_address
      order_ship_address
    end

    def origin_address
      addresses[:shipFrom] = {
        line1: @origin_address['Address1'],
        line2: @origin_address['Address2'],
        city: @origin_address['City'],
        region: @origin_address['Region'],
        postalCode: @origin_address['Zip5'],
        country: @origin_address['Country']
      }
    end

    def order_ship_address
      addresses[:shipTo] = {
        line1: @ship_address.address1,
        line2: @ship_address.address2,
        city: @ship_address.city,
        region: @ship_address.state.name,
        country: @ship_address.country.try(:iso),
        postalCode: @ship_address.zipcode
      }
    end

    private

    def validation_response(address)
      validator = TaxSvc.new
    end

    def stock_loc_ids
      order.shipments.pluck(:stock_location_id).uniq
    end
  end
end
