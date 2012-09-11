module DistributionPluginFactory

  def defaults_for_distribution_plugin_node
    {:profile => build(Enterprise), :role => 'supplier'}
  end

  def defaults_for_distribution_plugin_supplier
    {:node => build(DistributionPluginNode),
     :consumer => build(DistributionPluginNode)}
  end

  def defaults_for_distribution_plugin_product
    node = build(DistributionPluginNode)
    {:node => node, :name => "product-#{factory_num_seq}", :price => 2.0,
     :product => build(Product, :enterprise => node.profile, :price => 2.0),
     :supplier => build(DistributionPluginSupplier, :node => node, :consumer => node)}
  end

  def defaults_for_distribution_plugin_session_product
    defaults_for_distribution_plugin_product
  end

  def defaults_for_distribution_plugin_distributed_product
    defaults_for_distribution_plugin_product
  end

  def defaults_for_distribution_plugin_delivery_method
    {:node => build(DistributionPluginNode),
     :name => "My delivery #{factory_num_seq.to_s}",
     :delivery_type => 'deliver'}
  end

  def defaults_for_distribution_plugin_delivery_option
    {:session => build(DistributionPluginSession),
     :delivery_method => build(DistributionPluginDeliveryMethod)}
  end

  def defaults_for_distribution_plugin_session
    {:node => build(DistributionPluginNode), :status => 'orders',
     :name => 'weekly', :start => Time.now, :finish => Time.now+1.days}
  end

  def defaults_for_distribution_plugin_order
    node = build(DistributionPluginNode)
    {:status => 'confirmed',
     :session => build(DistributionPluginSession, :node => node),
     :consumer => build(DistributionPluginNode),
     :supplier_delivery => build(DistributionPluginDeliveryMethod, :node => node),
     :consumer_delivery => build(DistributionPluginDeliveryMethod, :node => node)}
  end

end

Noosfero::Factory.register_extension DistributionPluginFactory

