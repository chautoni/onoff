Spree::Admin::PaymentMethodsController.class_eval do
  private

  def load_data
    @providers = Spree::Gateway.providers.select{ |provider| ['Spree::BillingIntegration::PaypalExpress', 'Spree::PaymentMethod::CashOnDelivery'].include?(provider.name)  }
  end
end
