require 'csv'
require 'charlock_holmes'

class SuppliersPlugin::Import

  def self.products consumer, csv
    product_category = consumer.environment.product_categories.find_by_name 'Produtos'

    detection = CharlockHolmes::EncodingDetector.detect csv
    csv = CharlockHolmes::Converter.convert csv, detection[:encoding], 'UTF-8'
    data = {}
    header = []
    rows = []
    quote_chars = %w[" | ~ ^ & *]
    [",", ";", "\t"].each do |sep|
      begin
        rows = CSV.parse csv, quote_char: quote_chars.shift, col_sep: sep
        header = rows.shift if rows.size > 1 && (rows[0][0].downcase == 'supplier' or rows[0][0].downcase.strip == 'fornecedor')
      rescue
        if quote_chars.empty? then raise else retry end
      ensure
        break if rows.first.size == 4 or (rows.first.size == 5 and rows.first[4].blank?)
      end
    end
    raise 'invalid number of columns' unless rows.first.size == 4 or (rows.first.size == 5 and rows.first[4].blank?)

    rows.each do |row|
      supplier_name = row[0].to_s.squish
      product_name = row[1].to_s.squish.gsub('"', '&quot;')
      product_unit = row[2].to_s.squish
      product_price = row[3].to_s.squish

      product_unit = consumer.environment.units.find_by_singular product_unit

      data[supplier_name] ||= []
      data[supplier_name] << {name: product_name, unit: product_unit, price: product_price, product_category: product_category}
    end

    data.each do |supplier_name, products|
      supplier = consumer.suppliers.find_by_name supplier_name
      supplier ||= SuppliersPlugin::Supplier.create_dummy consumer: consumer, name: supplier_name

      products.each do |attributes|
        product = supplier.profile.products.find_by_name attributes[:name]
        product ||= supplier.profile.products.build attributes
        product.update_attributes! attributes
        # this is necessary on update
        product.distribute_to_consumer consumer
      end
    end
  end

end
