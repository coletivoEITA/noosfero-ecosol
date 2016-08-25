module SuppliersPlugin
  class ProductPageSerializer < ApplicationSerializer

    attribute :default_margin_percentage

    has_many :products
    has_many :units
    has_many :categories
    has_many :suppliers

    def default_margin_percentage
      profile.margin_percentage
    end

    def categories
      hash = {"0": scope.t('suppliers_plugin.views.product.all_the_categories')}
      Product.product_categories_of(products).each do |pc|
        hash[pc.id] = pc.name
      end
      hash
    end

    def suppliers
      hash = {"0": scope.t("suppliers_plugin.views.product.supplier")}
      s = profile.suppliers.order(:name_abbreviation, :name)
      s.each do |supplier|
        hash[supplier.id] = supplier.abbreviation_or_name
      end
      hash
    end

    def products
      params[:available] ||= 'true'

      # FIXME: joins(:from_products) is hiding own products (except baskets)
      SuppliersPlugin::BaseProduct.search_scope(profile.products, params)
        .unarchived
        .supplied
        .joins(:from_products, :suppliers)
        .includes(:image)
        .includes(:supplier_image)
        .order('from_product_name ASC')
        .where(suppliers_plugin_suppliers: {active: true})
        .select('products.*')
        .select('from_products_products.name    AS from_product_name')
        .select('from_products_products.unit_id AS from_product_unit_id')
        .select('from_products_products.price   AS from_product_price')
        .select('suppliers_plugin_suppliers.id  AS supplier_id')
        .group('suppliers_plugin_suppliers.id')
        .group('from_products_products.name')
        .group('from_products_products.unit_id')
        .group('from_products_products.price')
    end

    def units
      profile.environment.units.map do |unit|
        {name: unit.singular, id: unit.id}
      end
    end

    protected

    def profile
      object
    end

    def params
      instance_options
    end

  end
end
