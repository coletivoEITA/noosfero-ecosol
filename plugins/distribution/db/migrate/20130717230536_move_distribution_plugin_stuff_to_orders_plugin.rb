class DistributionPlugin::Order < Noosfero::Plugin::ActiveRecord
end
class DistributionPlugin::OrderedProduct < Noosfero::Plugin::ActiveRecord
end

class MoveDistributionPluginStuffToOrdersPlugin < ActiveRecord::Migration
  def self.up

  end

  def self.down
  end
end
