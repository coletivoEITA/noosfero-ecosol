if defined? OrdersPlugin
  require_dependency "#{File.dirname __FILE__}/../ext/orders_plugin/item"
end

class SuppliersPlugin::Base < Noosfero::Plugin

  def stylesheet?
    true
  end

  def js_files
    ['locale', 'toggle_edit', 'sortable-table', 'suppliers'].map{ |j| "javascripts/#{j}" }
  end

  def product_tabs product
    user = context.send :user
    profile = context.profile
    return unless user and user.has_permission? 'manage_products', profile
    return if profile.consumers.except_self.blank?
    {
      title: I18n.t('suppliers_plugin.lib.plugin.distribution_tab'), id: 'product-distribution',
      content: lambda{ render 'suppliers_plugin_manage_products/distribution_tab', product: product }
    }
  end

  def control_panel_buttons
    # FIXME: disable for now
    return

    profile = context.profile
    return unless profile.enterprise?
    [
      {title: I18n.t('suppliers_plugin.views.control_panel.suppliers'), icon: 'suppliers-manage-suppliers', url: {controller: :suppliers_plugin_myprofile, action: :index}},
      {title: I18n.t('suppliers_plugin.views.control_panel.products'), icon: 'suppliers-manage-suppliers', url: {controller: :suppliers_plugin_product, action: :index}},
    ]
  end

end

# make Product#decendants work to make it searchable
require_dependency 'suppliers_plugin/distributed_product'
