require_dependency "#{File.dirname __FILE__}/../ext/delivery_plugin/option"

require_dependency "#{File.dirname __FILE__}/../ext/suppliers_plugin/base_product"

class OrdersCyclePlugin::Base < Noosfero::Plugin

  def stylesheet?
    true
  end

  def js_files
    ['orders_cycle'].map{ |j| "javascripts/#{j}" }
  end

end

