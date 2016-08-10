module OrdersPlugin
  class ProductSearchSerializer < ApplicationSerializer

    attribute :value
    attribute :label

    def value
      object.id
    end

    def label
      "#{object.name} (#{supplier_name})"
    end

    def supplier_name
      if object.respond_to? :supplier and object.supplier.present?
        object.supplier.name
      else
        object.profile.short_name
      end
    end

  end
end
