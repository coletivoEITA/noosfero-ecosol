module SuppliersPlugin
  class ProductPageSerializer < ApplicationSerializer

    has_many :products
    has_many :units
    #has_many :categories
    has_many :suppliers

    def categories
      hash = {'': scope.t('suppliers_plugin.views.product.all_the_categories')}
      Product.product_categories_of(products).each do |pc|
        hash[pc.id] = pc.name
      end
    end

    def suppliers
      scope = profile.suppliers.order(:name_abbreviation, :name)
      scope.each.with_object({}) do |s, hash|
        hash[s.id] = s.abbreviation_or_name
      end
    end

    def products
      params[:available] ||= 'true'

      # FIXME: joins(:from_products) is hiding own products (except baskets)
      SuppliersPlugin::BaseProduct.search_scope(profile.products, params)
        .unarchived
        .supplied
        .joins(:from_products, :suppliers)
        .order('from_product_name ASC')
        .limit(20)
        .select(<<-EOQ
          products.*,
          from_products_products.name       AS from_product_name,
          suppliers_plugin_suppliers.id     AS supplier_id,
          suppliers_plugin_suppliers.active AS supplier_active
        EOQ
        ).group <<-EOQ
          suppliers_plugin_suppliers.id,
          from_products_products.name
        EOQ
    end

    def units
      profile.environment.units.each.with_object({}) do |u, hash|
        hash[u.id] = u.singular
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
