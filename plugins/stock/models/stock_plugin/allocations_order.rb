class StockPlugin::AllocationsOrder < ActiveRecord::Base

  belongs_to :order, class_name: "OrdersPlugin::Order"
  belongs_to :stock_allocation, class_name: "StockPlugin::Allocation"
end
