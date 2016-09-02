module SuppliersPlugin
  class ProductSerializer < ApplicationSerializer

    attribute :id
    attribute :name
    attribute :supplier_id
    attribute :product_category_id

    attribute :unit_id
    attribute :price
    attribute :supplier_price
    attribute :margin_percentage

    attribute :stored
    attribute :use_stock

    attribute :available

    has_one   :image_portrait
    has_one   :image_big

    def price
      product[:price]
    end

    def name
      product[:name] || product[:from_product_name]
    end
    def unit_id
      product[:unit_id] || product[:from_product_unit_id]
    end
    def supplier_price
      product[:from_product_price] || product.supplier_price
    end

    def available
      product[:available]
    end

    def supplier_id
      product[:supplier_id] || product.supplier_id
    end

    def margin_percentage
      product.own_margin_percentage
    end

    def image_portrait
      i = product.own_image || product.supplier_image
      return unless i

      i.public_filename :portrait
    end

    def image_big
      i = product.own_image || product.supplier_image
      return unless i

      i.public_filename :big
    end

    protected

    alias_method :product, :object
    alias_method :params, :instance_options

  end
end
