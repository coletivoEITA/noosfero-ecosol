module OrdersPlugin
  class PaymentSerializer < ApplicationSerializer

    attribute :value
    attribute :date
    attribute :method

    def date
      object.created_at.strftime("%d/%m/%Y")
    end

    def method
      object.payment_method.slug
    end

  end
end
