Spree::Payment.class_eval do
  attr_accessible :exchange_rate
  after_create :add_exchange_rate

  private

  def add_exchange_rate
    if self.payment_method.type == "Spree::BillingIntegration::PaypalExpress"
      self.update_attributes(:exchange_rate => Spree::Config[:usd_exchange_rate])
    end
  end
end
