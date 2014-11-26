# encoding: UTF-8

require_dependency 'manage_products_helper'

module ManageProductsHelper
  def select_unit(object)
    collection_select(object.class.name.downcase, :unit_id, environment.units, :id, :singular, {:include_blank => _('Select the unit')}, {:class => 'form-control'})
  end
end