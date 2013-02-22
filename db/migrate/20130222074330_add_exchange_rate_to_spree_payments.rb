class AddExchangeRateToSpreePayments < ActiveRecord::Migration
  def change
    add_column :spree_payments, :exchange_rate, :float, :default => 1
  end
end
