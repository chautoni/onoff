Spree::Admin::PaymentMethodsController.class_eval do
  private

  def load_data
    allowed_payment_methods = ['Spree::BillingIntegration::PaypalExpress', 'Spree::PaymentMethod::CashOnDelivery', 'Spree::PaymentMethod::BankTransfer']
    @providers = Spree::Gateway.providers.select{ |provider| allowed_payment_methods.include?(provider.name)  }
  end
end
