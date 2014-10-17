require 'iconv'
require 'rchardet'

class SuppliersPlugin::Import

  def self.products consumer, csv
    encoding = CharDet.detect(csv)['encoding']
    #i = Iconv.new 'UTF-8//IGNORE', 'UTF-8'
    i = Iconv.new 'UTF-8', encoding
    product_category = consumer.environment.product_categories.find_by_name 'Produtos'

    data = {}
    header = []
    rows = []
    [",", ";", "\t"].each do |sep|
      rows = CSV.parse csv, :col_sep => sep
      header = rows.shift
      break if header.size == 4
    end
    raise 'invalid number of columns' unless header.size == 4

    rows.each do |row|
      supplier_name = i.iconv row[0].to_s.squish
      product_name = i.iconv row[1].to_s.squish
      product_unit = i.iconv row[2].to_s.squish
      product_price = i.iconv row[3].to_s.squish

      product_unit = consumer.environment.units.find_by_singular product_unit

      data[supplier_name] ||= []
      data[supplier_name] << {:name => product_name, :unit => product_unit, :price => product_price, :product_category => product_category}
    end

    data.each do |supplier_name, products|
      supplier = consumer.suppliers.find_by_name supplier_name
      supplier ||= SuppliersPlugin::Supplier.create_dummy :consumer => consumer, :name => supplier_name

      products.each do |attributes|
        product = supplier.profile.products.find_by_name attributes[:name]
        product ||= supplier.profile.products.build attributes
        product.update_attributes! attributes
      end
    end
  end

end
