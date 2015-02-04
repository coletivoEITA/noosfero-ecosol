class MoveShoppingDeliveryOptionsToDeliveryPlugin < ActiveRecord::Migration
  def up
    Enterprise.find_each batch_size: 20 do |enterprise|
      next if enterprise.shopping_cart_settings.delivery_options.empty?

      free_over_price = enterprise.shopping_cart_settings.free_delivery_price
      enterprise.shopping_cart_settings.delivery_options.each do |name, price|
        enterprise.delivery_methods.create! name: name, fixed_cost: price.to_f, delivery_type: 'pickup', free_over_price: free_over_price
      end

      enterprise.shopping_cart_settings.free_delivery_price = nil
      enterprise.shopping_cart_settings.delivery_options = nil
      enterprise.save!
    end
  end

  def down
    say "this migration can't be reverted"
  end
end
