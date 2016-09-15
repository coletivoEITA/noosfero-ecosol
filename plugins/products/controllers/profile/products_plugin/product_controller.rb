module ProductsPlugin
  class ProductController < ProfileController
    include ProductsPlugin::Spreadsheet
    include ProductsPlugin::TranslationHelper

    def spreadsheet
      @products = profile
        .distributed_products
        .available
        .unarchived
        .includes(:unit, :product_category)
        .joins(:from_products, :supplier)
        .select("products.name")
        .select("products.id")
        .select("products.unit_id")
        .select("products.data")
        .select("products.price")
        .select("products.profile_id")
        .select("products.product_category_id")
        .select("suppliers_plugin_suppliers.name")
        .select("suppliers_plugin_suppliers.name_abbreviation")
        .select("suppliers_plugin_suppliers.id")
        .select("suppliers_plugin_suppliers.consumer_id")
        .select('from_products_products.unit_id AS from_product_unit_id')
        .select('from_products_products.price   AS from_product_price')
        .select("units.singular")
        .select("categories.name")
        .select("categories.id")
        .where(suppliers_plugin_suppliers: {active: true})
        .reorder("suppliers_plugin_suppliers.name","categories.name", "products.name")

      spreadsheet_file = products_spreadsheet Product.products_by_supplier(@products), profile.name

      send_file spreadsheet_file, type: 'application/xlsx',
        disposition: 'attachment',
        filename: t('controllers.product.spreadsheet') % {
          date: DateTime.now.strftime("%Y-%m-%d"), profile_identifier: profile.identifier}
    end
  end
end
