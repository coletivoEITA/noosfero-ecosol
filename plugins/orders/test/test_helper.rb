require 'test_helper'

module BackgroundJobs
  def run_background_jobs_immediately
    delay_jobs = Delayed::Worker.delay_jobs
    Delayed::Worker.delay_jobs = false
    yield
    Delayed::Worker.delay_jobs = delay_jobs
  end
end

module OrdersTestHelper

  attr_accessor :profile, :supplier, :product, :cycle, :user

  include BackgroundJobs

  def setup
    @profile = create_coop
    @supplier = create_supplier @profile
    create(ProductCategory, name: 'first product category', environment_id: Environment.default.id)
    @product = create_product @supplier, 'product1'
    @cycle = create_cycle @profile
    @user = User.create!(:environment_id => Environment.default.id, :email => "user@domain.com", :login   => "new_user", :password => "test", :password_confirmation => "test", :name => "UserName")
    @profile.add_member @user.person
  end

  def create_coop
    profile = create Community
    profile.consumers_coop_settings.enable = true
    profile.consumers_coop_enable
    profile
  end

  def create_supplier profile
    supplier = create Enterprise
    profile.add_supplier supplier
    supplier
  end

  def create_product supplier, name
    product = supplier.products.new name: name, product_category: ProductCategory.last , price: 10, available: true
    product.save!
    product
  end

  def create_cycle profile
    run_background_jobs_immediately do
      @cycle = profile.orders_cycles.create name: "test cycle 1",
        start: Time.now,
        finish: Time.now + 1.day,
        delivery_start: Time.now + 2.day,
        delivery_finish: Time.now + 2.day + 1.hour,
        status: 'new'
      @cycle.status = 'orders'
      @cycle.save
    end
    @cycle
  end

  def create_default_sale_with_item cycle, profile
    value = 1
    product = cycle.products.first
    sale = create_sale cycle, profile, 'draft'
    sale.items.create! product: product, quantity_consumer_ordered: value
    sale
  end

  def create_sale cycle, profile, status
    @order = OrdersCyclePlugin::Sale.new status: status
    @order.profile = profile
    @order.consumer = user.person
    @order.cycle = cycle
    @order.save!
    @order
  end
end
