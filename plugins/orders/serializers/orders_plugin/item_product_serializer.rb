module OrdersPlugin
  class ItemProductSerializer < ApplicationSerializer

    attribute :minimum_selleable_localized

    # unit_name used instead
    #has_one :unit, serializer: ItemUnitSerializer

  end
end
