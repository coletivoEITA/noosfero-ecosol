require_dependency "#{File.dirname __FILE__}/../ext/delivery_plugin/option"

class OrdersCyclePlugin::Base < Noosfero::Plugin

  def stylesheet?
    true
  end

  def js_files
    ['orders_cycle'].map{ |j| "javascripts/#{j}" }
  end

  def self.extra_blocks
    {
      OrdersCyclePlugin::OrdersCycleHappeningBlock => {type: [Community]}
    }
  end
end

