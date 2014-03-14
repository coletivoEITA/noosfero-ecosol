class OrdersPlugin::Order < Noosfero::Plugin::ActiveRecord

  belongs_to :profile
  belongs_to :consumer, :class_name => 'Profile'

  has_many :items, :class_name => 'OrdersPlugin::Item', :foreign_key => :order_id, :dependent => :destroy,
    :include => [{:product => [{:profile => [:domains]}]}], :order => 'products.name ASC'

  has_many :products, :through => :items

  belongs_to :supplier_delivery, :class_name => 'DeliveryPlugin::Method'
  belongs_to :consumer_delivery, :class_name => 'DeliveryPlugin::Method'

  Statuses = ['draft', 'planned', 'confirmed', 'cancelled', 'accepted', 'shipped']
  StatusText = {
   'open' => 'orders_plugin.models.order.open',
   'forgotten' => 'orders_plugin.models.order.not_confirmed',
   'planned' => 'orders_plugin.models.order.planned',
   'confirmed' => 'orders_plugin.models.order.confirmed',
   'cancelled' => 'orders_plugin.models.order.cancelled',
   'accepted' => 'orders_plugin.models.order.accepted',
   'shipped' => 'orders_plugin.models.order.shipped',
  }
  validates_inclusion_of :status, :in => Statuses
  before_validation :default_values

  extend CodeNumbering::ClassMethods
  code_numbering :code, :scope => proc{ self.profile.orders }

  extend SerializedSyncedData::ClassMethods
  sync_serialized_field :profile do |profile|
    {:name => profile.name, :email => profile.contact_email}
  end
  sync_serialized_field :consumer do |consumer|
    if consumer.blank? then {} else
      {:name => consumer.name, :email => consumer.contact_email, :contact_phone => consumer.contact_phone}
    end
  end
  sync_serialized_field :supplier_delivery
  sync_serialized_field :consumer_delivery
  serialize :payment_data, Hash

  named_scope :draft, :conditions => {:status => 'draft'}
  named_scope :planned, :conditions => {:status => 'planned'}
  named_scope :confirmed, :conditions => {:status => 'confirmed'}
  named_scope :cancelled, :conditions => {:status => 'cancelled'}

  named_scope :for_consumer, lambda { |consumer| {
    :conditions => {:consumer_id => consumer ? consumer.id : nil} }
  }
  named_scope :for_profile, lambda { |profile| {
    :conditions => {:profile_id => profile ? profile.id : nil} }
  }
  named_scope :with_status, lambda { |status|
    {:conditions => {:status => status}}
  }
  named_scope :with_code, lambda { |code|
    {:conditions => {:code => code}}
  }

  def self.search_scope scope, params
    scope = scope.with_status params[:status] if params[:status].present?
    scope = scope.for_consumer params[:consumer_id] if params[:consumer_id].present?
    scope = scope.for_profile params[:profile_id] if params[:profile_id].present?
    scope = scope.with_code params[:code] if params[:code].present?
    scope
  end

  # All products from the order profile?
  def self_supplier?
    return @single_supplier unless @single_supplier.nil?

    self.products.each do |p|
      return @single_supplier = false unless p.supplier.self?
    end
    @single_supplier = true
  end

  def draft?
    self.status == 'draft'
  end
  def open?
    self.draft?
  end
  def planned?
    self.status == 'planned'
  end
  def confirmed?
    self.status == 'confirmed'
  end
  def cancelled?
    self.status == 'cancelled'
  end

  def current_status
    return 'forgotten' if self.forgotten?
    return 'open' if self.open?
    self['status']
  end
  def status_message
    I18n.t StatusText[current_status]
  end

  def may_view? user
    @may_view ||= self.profile.admins.include?(user) or (self.consumer == user)
  end

  # cache if done independent of user as model cache is per request
  def may_edit? user
    @may_edit ||= self.profile.admins.include?(user) or (self.open? and self.consumer == user)
  end

  def products_list
    hash = {}; self.items.map do |item|
      hash[item.product_id] = {:quantity => item.quantity_asked, :name => item.name, :price => item.price}
    end
    hash
  end
  def products_list= hash
    self.items = hash.map do |id, data|
      data[:product_id] = id
      data[:quantity_asked] = data.delete(:quantity)
      data[:order] = self
      OrdersPlugin::Item.new data
    end
  end

  def total_quantity_asked
    self.items.collect(&:quantity_asked).inject(0){ |sum,q| sum+q }
  end
  def total_price_asked
    self.items.collect(&:price_asked).inject(0){ |sum,q| sum+q }
  end

  def parcel_quantity_total
    #TODO
    total_quantity_asked
  end
  def parcel_price_total
    #TODO
    total_price_asked
  end

  def products_by_supplier
    self.items.group_by{ |i| i.supplier.abbreviation_or_name }
  end

  extend CurrencyHelper::ClassMethods
  has_number_with_locale :total_quantity_asked
  has_number_with_locale :parcel_quantity_total
  has_currency :total_price_asked
  has_currency :parcel_price_total

  protected

  def default_values
    self.status ||= 'draft'
  end

end
