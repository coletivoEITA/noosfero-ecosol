module DistributionPlugin::Factory

  def defaults_for_distribution_plugin_node
    {:profile => build(Enterprise), :role => 'supplier'}
  end

  def defaults_for_distribution_plugin_supplier
    {:node => build(DistributionPlugin::Node),
     :consumer => build(DistributionPlugin::Node)}
  end

  def defaults_for_distribution_plugin_product(attrs = {})
    node = attrs[:node] || build(DistributionPlugin::Node)
    {:node => node, :name => "product-#{factory_num_seq}", :price => 2.0,
     :product => build(Product, :enterprise => node.profile, :price => 2.0),
     :supplier => build(SuppliersPlugin::Supplier, :node => node, :consumer => node)}
  end

  def defaults_for_distribution_plugin_distributed_product(attrs = {})
    defaults_for_distribution_plugin_product(attrs)
  end

  def defaults_for_distribution_plugin_offered_product(attrs = {})
    hash = defaults_for_distribution_plugin_product(attrs)
    node = hash[:node]
    hash.merge({
      :from_products => [build(SuppliersPlugin::DistributedProduct, :node => node)]})
  end

  def defaults_for_distribution_plugin_delivery_method
    {:node => build(DistributionPlugin::Node),
     :name => "My delivery #{factory_num_seq.to_s}",
     :delivery_type => 'deliver'}
  end

  def defaults_for_distribution_plugin_delivery_option
    {:session => build(DistributionPlugin::Session),
     :delivery_method => build(DeliveryPlugin::Method)}
  end

  def defaults_for_distribution_plugin_session
    {:node => build(DistributionPlugin::Node), :status => 'orders',
     :name => 'weekly', :start => Time.now, :finish => Time.now+1.days}
  end

  def defaults_for_distribution_plugin_order(attrs = {})
    node = attrs[:node] || build(DistributionPlugin::Node)
    {:status => 'confirmed',
     :session => build(DistributionPlugin::Session, :node => node),
     :consumer => build(DistributionPlugin::Node),
     :supplier_delivery => build(DeliveryPlugin::Method, :node => node),
     :consumer_delivery => build(DeliveryPlugin::Method, :node => node)}
  end

  def defaults_for_distribution_plugin_ordered_product
    {:order => build(OrdersPlugin::Order),
     :product => build(DistributionPlugin::OfferedProduct),
     :quantity_payed => 1.0, :quantity_asked => 2.0, :quantity_allocated => 3.0,
     :price_payed => 10.0, :price_asked => 20.0, :price_allocated => 30.0}
  end

end

Noosfero::Factory.register_extension DistributionPlugin::Factory

