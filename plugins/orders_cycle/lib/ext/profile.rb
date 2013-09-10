require_dependency 'profile'

class Profile

  has_many :orders_cycles, :class_name => 'OrdersCyclePlugin::Cycle', :dependent => :destroy, :order => 'created_at DESC',
    :conditions => ["orders_cycle_plugin_cycles.status <> 'new'"]

  has_many :offered_products, :through => :profile, :order => 'products.name ASC'

  has_many :cycles_custom_order, :class_name => 'OrdersCyclePlugin::Cycle',
    :conditions => ["orders_cycle_plugin_cycles.status <> 'new'"]

  def orders_cycles_closed_date_range
    list = self.orders_cycles.not_open.all :order => 'start ASC'
    return DateTime.now..DateTime.now if list.blank?
    list.first.start.to_date..list.last.finish.to_date
  end

  def orders_cycles_products_default_margins
    self.class.transaction do
      self.orders_cycles.open.each do |cycle|
        cycle.products.each do |product|
          product.margin_percentage = margin_percentage
          product.save!
        end
      end
    end
  end

end
