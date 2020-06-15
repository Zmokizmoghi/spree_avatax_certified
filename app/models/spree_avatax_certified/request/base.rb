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
        order.completed_at.strftime('%F')
      end

      def base_tax_hash
        out = {
          customerCode: customer_code,
          companyCode: company_code,
          email: order.email,
          date: doc_date,
          lines: sales_lines,
          addresses: address_lines
        }

        out
      end

      def address_lines
        @address_lines ||= SpreeAvataxCertified::Address.new(order).addresses
      end

      def sales_lines
        @sales_lines ||= SpreeAvataxCertified::Line.new(order, @doc_type, @refund).lines # @refund == nil if its not refund transaction
      end

      def company_code
        @company_code ||= Spree::Config.avatax_company_code
      end

      def customer_code
        order.user ? order.user.id : order.email
      end
    end
  end
end
