class AggregateProductPlugin::Base < Noosfero::Plugin

  def product_tabs product
    user = context.send :user
    profile = context.profile
    return unless user and user.has_permission? 'manage_products', profile
    return if profile.consumers.except_self.blank?
    {
      title: I18n.t('aggregate_product_plugin.views.manage_products.tab_title'), id: 'product-aggregation',
      content: lambda do
        render 'aggregate_product_plugin/manage_products/show', product: product
      end
    }
  end

end
