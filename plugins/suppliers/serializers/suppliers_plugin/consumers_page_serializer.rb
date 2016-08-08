module SuppliersPlugin
  class ConsumersPageSerializer < ApplicationSerializer

    has_many :consumers
    has_many :hubs

    def consumers
      object.consumers.except_self.order(:name)
    end

    def hubs
      object.hubs
    end

  end
end
