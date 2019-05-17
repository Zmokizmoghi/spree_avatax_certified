module SpreeAvataxCertified
  module Request
    class Base
      attr_reader :order, :request

      def initialize(order, opts={})
        @order = order
        @doc_type = opts[:doc_type]
        @commit = opts[:commit]
        @request = {}
      end

      def generate
        raise 'Method needs to be implemented in subclass.'
      end

      protected

      def doc_date
        order.completed? ? order.completed_at.strftime('%F') : Date.today.strftime('%F')
      end

      def base_tax_hash
        {
          customerCode: customer_code,
          companyCode: company_code,
          email: order.email,
          date: doc_date,
          lines: sales_lines
        }
      end

       # If there is a vat id, set BusinessIdentificationNo
      def check_vat_id
        if !business_id_no.blank?
          @request[:BusinessIdentificationNo] = business_id_no
        end
      end

      def address_lines
        @address_lines ||= SpreeAvataxCertified::Address.new(order).addresses
      end

      def sales_lines
        @sales_lines ||= SpreeAvataxCertified::Line.new(order, @doc_type).lines
      end

      def company_code
        @company_code ||= Spree::Config.avatax_company_code
      end

      def business_id_no
        order.user.try(:vat_id)
      end

      def customer_code
        order.user ? order.user.id : order.email
      end
    end
  end
end
