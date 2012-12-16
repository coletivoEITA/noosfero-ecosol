require 'rubygems'
require 'faster_csv'
CSV = FasterCSV

class DistributionPlugin::Import

  def self.terramater_db(node, supplier_csv, products_csv, supplier_products_csv, verbose=true)
    id_s = {}
    CSV.readlines(supplier_csv,:headers => true).each do |row|
      s = DistributionPluginSupplier.create_dummy :consumer => node, :name => row[1]
      id_s[row[0]] = s
      puts row[3] if verbose
      s.profile.update_attributes! :contact_phone => row[2], :contact_email => ((row[3] and row[3].include?'@')? row[3].strip : nil)
    end

    id_p = {}
    CSV.readlines(products_csv,:headers => true).each do |row|
      if row[1] =~  /(.+?) - (.+)/  # check for a description
        name = $1; description = $2
      else
        name = row[1]
        description = ''
      end
      product =  DistributionPluginDistributedProduct.new :node => node, :name => name, :description => description, :active => row[2]
      puts row[1] if product.nil? and verbose
      id_p[row[0]] = product
    end

    CSV.readlines(supplier_products_csv,:headers=> true).each do |row|
      s = id_s[row[0]]
      p = id_p[row[1]]
      puts row[1] if p.nil? and verbose
      p.supplier = s
      print "#{s.name} - #{p.name}"
      print " - p: #{row[2]}" if !row[2].nil? and verbose
      puts " - m: "+ row[3] if !row[3].nil? and verbose
      print "\n\n"
      p.update_attributes :supplier_product => {:price => row[2], :margin_percentage => row[3]}
      p.save!
    end

    true
  end

end
