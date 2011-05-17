module DistributionFactory

  def factory_num_seq
    Noosfero::Factory.num_seq
  end

  def defaults_for_distribution_delivery_method
    { :name => 'My delivery ' + factory_num_seq.to_s }
  end

  def defaults_for_distribution_order
    {:order_session_id => 1, :consumer_id => 1, :supplier_delivery_id => 1, :consumer_delivery_id => 1} 
  end

  def defaults_for_distribution_node
    {:profile_id => 1, :role => 'supplier'}
  end

  def defaults_for_distribution_product
    {:node_id => 1, :product_id => 1}
  end
end

