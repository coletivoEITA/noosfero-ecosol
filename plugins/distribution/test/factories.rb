module DistributionFactory

  def factory_num_seq
    Noosfero::Factory.num_seq
  end

  def defaults_for_distribution_delivery_method
    { :name => 'My delivery ' + factory_num_seq.to_s , :delivery_type => 'delivery'}
  end

  def defaults_for_distribution_order
    {:session_id => 1, :consumer_id => 1, :supplier_delivery_id => 1, :consumer_delivery_id => 2} 
  end

  def defaults_for_distribution_node
    {:profile_id => 1, :role => 'supplier'}
  end

  def defaults_for_distribution_session
    {:node_id => 1, :name => 'o_de_sempre', :start => Time.now, :finish => Time.now+1.days}
  end

  def defaults_for_distribution_product
    {:node_id => 1, :product_id => 1}
  end

  def defaults_for_distribution_delivery_option
    {:session_id => 1, :delivery_method => 1}
  end
end

