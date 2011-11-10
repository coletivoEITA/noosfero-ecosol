module DistributionPluginFactory

  def factory_num_seq
    Noosfero::Factory.num_seq
  end

  def defaults_for_distribution_plugin_delivery_method
    { :name => 'My delivery ' + factory_num_seq.to_s , :delivery_type => 'deliver'}
  end

  def defaults_for_distribution_plugin_order
    {:session_id => 1, :consumer_id => 1, :supplier_delivery_id => 1, :consumer_delivery_id => 2} 
  end

  def defaults_for_distribution_plugin_node
    {:profile_id => 1, :role => 'supplier'}
  end

  def defaults_for_distribution_plugin_session
    {:node_id => 1, :name => 'o_de_sempre', :start => Time.now, :finish => Time.now+1.days}
  end

  def defaults_for_distribution_plugin_product
    n = factory_num_seq
    {:node_id => 1, :product_id => 1, :supplier_id => 1, :name => "product-#{n}"}
  end

  def defaults_for_distribution_plugin_session_product
    defaults_for_distribution_plugin_product
  end

  def defaults_for_distribution_plugin_distributed_product
    defaults_for_distribution_plugin_product
  end

  def defaults_for_distribution_plugin_delivery_option
    {:session_id => 1, :delivery_method => 1}
  end
end

