module SpreeAvataxCertified
  class Line
    attr_reader :order, :lines

    def initialize(order, invoice_type, refund = nil)
      @order = order
      @invoice_type = invoice_type
      @lines = []
      @refund = refund
      @refunds = []
      build_lines
    end

    def build_lines
      if %w(ReturnInvoice ReturnOrder).include?(@invoice_type)
        refund_lines
      else
        item_lines_array
        shipment_lines_array
      end
    end

    def item_line(line_item)
      li_id = if line_item.id.present?
        line_item.id
      else
        Time.current.to_i
      end


      {
        number: "#{li_id}-#{line_item.avatax_line_code}-#{rand(9999)}",
        description: line_item.name[0..255],
        taxCode: line_item.tax_category.try(:tax_code) || 'P0000000',
        itemCode: line_item.variant.sku,
        quantity: line_item.quantity,
        amount: line_item.amount.to_f,
        addresses: nil,
        discounted: discounted?(line_item),
        taxIncluded: tax_included_in_price?(line_item)
      }
    end

    def item_lines_array
      order.line_items.each do |line_item|
        lines << item_line(line_item)
      end
    end

    def shipment_lines_array
      order.shipments.each do |shipment|
        next unless shipment.tax_category
        lines << shipment_line(shipment)
      end
    end

    def shipment_line(shipment)
      {
        number: "#{shipment.id}-FR",
        itemCode: shipment.shipping_method.admin_name.truncate(50),
        quantity: 1,
        amount: shipment.discounted_amount.to_f,
        addresses: nil,
        description: 'Shipping Charge',
        taxCode: shipment.shipping_method_tax_code,
        discounted: false,
        taxIncluded: tax_included_in_price?(shipment)
      }
    end

    def refund_lines
      return lines << refund_line if @refund.reimbursement.nil?

      return_items = @refund.reimbursement.customer_return.return_items
      inventory_units = Spree::InventoryUnit.where(id: return_items.pluck(:inventory_unit_id))

      inventory_units.group_by(&:line_item_id).each_value do |inv_unit|

        inv_unit_ids = inv_unit.map { |iu| iu.id }
        return_items = Spree::ReturnItem.where(inventory_unit_id: inv_unit_ids)
        quantity = inv_unit.uniq.count
        amount = return_items.sum(:pre_tax_amount)

        lines << return_item_line(inv_unit.first.line_item, quantity, amount)
      end
    end

    def refund_line
      {
        number: "#{@refund.id}-RA",
        itemCode: @refund.transaction_id || 'Refund',
        quantity: 1,
        amount: -@refund.amount.to_f,
        description: 'Refund',
        taxIncluded: true,
        addresses: nil
      }
    end

    def return_item_line(line_item, quantity, amount)
      {
        number: "#{line_item.id}-#{line_item.avatax_line_code}",
        description: line_item.name[0..255],
        taxCode: line_item.tax_category.try(:tax_code) || 'P0000000',
        itemCode: line_item.variant.sku,
        quantity: quantity,
        amount: -amount.to_f
      }
    end

    private

    def discounted?(line_item)
      line_item.adjustments.promotion.eligible.any? || order.adjustments.promotion.eligible.any?
    end

    def tax_included_in_price?(item)
      if item.tax_category.present?
        order.tax_zone.tax_rates.where(tax_category: item.tax_category).try(:first).try(:included_in_price)
      else
        order.tax_zone.tax_rates.try(:first).try(:included_in_price)
      end
    end
  end
end
