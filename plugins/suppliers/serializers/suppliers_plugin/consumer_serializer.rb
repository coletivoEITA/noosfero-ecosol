module SuppliersPlugin
  class ConsumerSerializer < ApplicationSerializer

    attribute :name
    attribute :contact_email
    attribute :short_name
    attribute :profile_icon_thumb
    attribute :identifier

    #has_one :profile

    def short_name
      object.short_name(nil)
    end
    def profile_icon_thumb
      scope.profile_icon(object, :thumb)
    end
  end
end
