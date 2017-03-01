module SuppliersPlugin
  class ProfileSerializer < ApplicationSerializer

    attribute :id
    attribute :name
    attribute :contact_phone
    attribute :cell_phone
    attribute :email
    attribute :address
    attribute :city
    attribute :state
    attribute :zip_code
    attribute :profile_icon_thumb
    attribute :identifier

    def profile_icon_thumb
      scope.profile_icon(object, :thumb)
    end

  end
end

