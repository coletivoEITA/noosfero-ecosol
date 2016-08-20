module SuppliersPlugin
  class ProductPageSerializer < ApplicationSerializer

    has_many :products
    has_many :units
    has_many :categories
    has_many :suppliers

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
      scope = profile.products.unarchived.joins :from_products, :suppliers
      scope = SuppliersPlugin::BaseProduct.search_scope scope, params
      scope = scope.supplied.select('products.*, MIN(from_products_products.name) as from_products_name').order('from_products_name ASC')
      scope.limit(10)
      #scope = scope
        #.select('from_products_products.price AS supplier_price')
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
