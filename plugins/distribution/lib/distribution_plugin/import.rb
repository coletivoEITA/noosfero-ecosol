require 'rubygems'
require 'faster_csv'

class DistributionPlugin::Import

  def self.terramater_db(node, supplier_csv, products_csv, supplier_products_csv)
    id_s = {}
    FasterCSV.open(supplier_csv).readlines.each do |row|
      s = DistributionPluginSupplier.create_dummy :consumer => node, :name => row[1]
      id_s[row[0]] = s
      s.profile.update_attributes! :contact_phone => row[6], :contact_email => (row[7] == 'xx' ? row[7] : nil)
    end

    id_p = {}
    FasterCSV.open(products_csv).readlines.each do |row|
      id_p[row[0]] = DistributionPluginDistributedProduct.new :node => node, :name => row[1], :active => row[8]
    end

    FasterCSV.open(supplier_products_csv).readlines.each do |row|
      s = id_s[row[1]]
      p = id_p[row[2]]
      p.supplier = s
      p.update_attributes :supplier_product => {:margin_percentage => row[4], :price => row[3]}
    end

    true
  end

end
