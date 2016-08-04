module SuppliersPlugin
  class ConsumerSerializer < ApplicationSerializer

    attribute :consumer_id
    attribute :name
    attribute :contact_email
    attribute :short_name
    attribute :profile_icon_thumb
    attribute :identifier

    has_many :purchases, serializer: PurchaseSerializer

    #has_one :profile

    def short_name
      object.short_name(nil)
    end
    def profile_icon_thumb
      scope.profile_icon(object, :thumb)
    end

    def purchases
      object.purchases.last(10).map{|p| p.becomes OrdersCyclePlugin::Sale }.select{|p| p.cycle }
    end
  end
end
