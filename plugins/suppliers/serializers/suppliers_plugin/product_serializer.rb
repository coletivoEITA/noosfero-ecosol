module SuppliersPlugin
  class ProductSerializer < ApplicationSerializer

    attribute :name
    attribute :price
    attribute :image
    attribute :supplier_id
    attribute :product_category_id
    attribute :margin_percentage
    attribute :stored
    attribute :use_stock
    attribute :available
    attribute :unit_id
    attribute :supplier_price

    def supplier_price
      object.supplier_price
    end
    def price
      object.price_as_currency
    end

    def image
      object.default_image(:thumb)
    end

  end
end
