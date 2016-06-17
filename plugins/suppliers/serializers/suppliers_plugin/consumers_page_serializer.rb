module SuppliersPlugin
  class ConsumersPageSerializer < ApplicationSerializer

    has_many :consumers

    def consumers
      object.consumers.except_self
    end
  end
end

