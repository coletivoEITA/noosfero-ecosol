module DistributionPluginFactory

  def defaults_for_distribution_plugin_node
    {:profile => build(Profile), :role => 'supplier'}
  end

  def defaults_for_distribution_plugin_supplier
    {:node => build(DistributionPluginNode),
     :consumer => build(DistributionPluginNode)}
  end

  def defaults_for_distribution_plugin_product
    node = build(DistributionPluginNode)
    {:node => node, :name => "product-#{factory_num_seq}",
     :product => build(Product), :price => 2.0,
     :supplier => build(DistributionPluginSupplier)}
  end

  def defaults_for_distribution_plugin_session_product
    defaults_for_distribution_plugin_product
  end

  def defaults_for_distribution_plugin_distributed_product
    defaults_for_distribution_plugin_product
  end

  def defaults_for_distribution_plugin_delivery_method
    {:name => "My delivery #{factory_num_seq.to_s}", :delivery_type => 'deliver'}
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
    {:session => build(DistributionPluginSession),
     :consumer => build(DistributionPluginNode),
     :supplier_delivery => build(DistributionPluginDeliveryMethod),
     :consumer_delivery => build(DistributionPluginDeliveryMethod)}
  end

end

Noosfero::Factory.register_extension DistributionPluginFactory

