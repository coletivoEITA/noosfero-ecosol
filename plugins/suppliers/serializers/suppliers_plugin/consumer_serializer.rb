module SuppliersPlugin
  class ConsumerSerializer < ApplicationSerializer

    attribute :id
    attribute :consumer_id
    attribute :name
    attribute :profile_name
    attribute :phone
    attribute :cell_phone
    attribute :email
    attribute :hub_id
    attribute :address
    attribute :city
    attribute :state
    attribute :zip
    attribute :profile_icon_thumb
    attribute :identifier

    has_many :purchases

    def profile_icon_thumb
      scope.profile_icon(object, :thumb)
    end

    def purchases
      []
    end

    def profile_name
      object.profile.name
    end
  end
end
