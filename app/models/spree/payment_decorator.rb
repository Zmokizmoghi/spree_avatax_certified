Spree::Payment.class_eval do
  self.state_machine.before_transition to: :completed, do: :avalara_finalize
  self.state_machine.after_transition to: :void, do: :cancel_avalara

  def avalara_tax_enabled?
    Spree::Config.avatax_tax_calculation
  end

  def cancel_avalara
    order.avalara_transaction.cancel_order unless order.avalara_transaction.nil?
  end

  def avalara_finalize
    return unless avalara_tax_enabled?

    if self.amount != order.total
      self.update_attributes(amount: order.total)
    end

    begin
      order.avalara_capture_finalize
    rescue => e
      if defined?(Raven)
        Raven.capture_message("Could not pass payment info to avalara",
                                  user: { error: e.message, backtrace: e.backtrace },
                                  tags: { order_number: order.number, paymment_number: self.number })
      end
    end
  end
end
