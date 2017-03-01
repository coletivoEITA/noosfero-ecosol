module OrdersCyclePlugin
  class SaleSerializer < ApplicationSerializer

    attribute :total_price
    attribute :status
    has_one :date
    has_one :cycle
    has_one :value_ordered
    has_one :final_value

    def date
      object.created_at.strftime "%d/%m/%Y"
    end
    def cycle
      object.cycle.name
    end
    def value_ordered
      object.total_price_consumer_ordered_as_currency
    end
    def final_value
      object.total_price_consumer_received_as_currency
    end
  end
end

