module DistributionPlugin::Report
  module ClassMethods
    def report_products_by_supplier(ordered_products_by_supplier)
      if ordered_products_by_supplier.blank? or not defined? ::ODF::Spreadsheet 
        return [nil, nil]
      end 

      tmp_dir = Dir.mktmpdir "noosfero-" 
      report_file = tmp_dir + '/report.ods'
      ::ODF::Spreadsheet.file report_file do |spreadsheet| 
        # create styles
        spreadsheet.style 'green-cell', :family => :cell do |style|
          style.property :text, 'font-weight' => 'bold', 'color' => '#00ff00'
        end
        spreadsheet.style 'blue-cell', :family => :cell do |style|
          style.property :text, 'font-weight' => 'bold', 'color' => '#0000ff'
        end
        spreadsheet.style 'red-cell', :family => :cell do |style|
          style.property :text, 'font-weight' => 'bold', 'color' => '#ff3010', 'background-color' => '#aaccbb'
        end
        spreadsheet.style 'larger-column', :family => :column do |style|
          style.property :column, 'column-width' => '200px'
        end
        # create sheet and populates
        spreadsheet.table 'Products sheet' do |table|
          ordered_products_by_supplier.each do |supplier, ordered_products, total_price_asked|
            table.row do |row|
              row.cell _("Supplier"), :style => 'blue-cell'
              row.cell _("Total selled value"), :style => 'blue-cell'
              #row.cell _("Total parcel value"), :style => 'blue-cell'
            end
            table.row do |row|
              row.cell supplier.name
              row.cell total_price_asked
              #row.cell _("formula")
            end
            table.row do |row| # empty line
              row.cell ""
              row.cell ""
              row.cell ""
            end
            table.row do |row|
              row.cell _("product cod."), :style => 'green-cell'
              row.cell _("product name"), :style => 'green-cell'
              row.cell _("qtt ordered"), :style => 'green-cell'
              row.cell _("min. qtt"), :style => 'green-cell'
              #row.cell _("qtt to be parcelled"), :style => 'green-cell'
              #row.cell _("projected stock"), :style => 'green-cell'
              row.cell  _("un."), :style => 'green-cell'
              row.cell _("price/un"), :style => 'green-cell'
              row.cell _("selled value"), :style => 'green-cell'
              #row.cell _("Parcel value") , :style => 'green-cell'
            end
            ordered_products.each do |ordered_product| 
              table.row do |row|
                row.cell ordered_product.product.id
                row.cell ordered_product.product.name
                row.cell ordered_product.total_quantity_asked
                row.cell ordered_product.minimum_selleable
                #row.cell "formula"
                #row.cell "formula"
                row.cell ordered_product.unit.singular
                row.cell ordered_product.price_asked
                row.cell ordered_product.total_price_asked
                #row.cell "formula"
              end 
            end # closes ordered_products.each
            table.row do |row|
              row.cell ""
              row.cell ""
              row.cell ""
            end
          end # closes ordered_products_by_supplier
          table.row do |row|
            row.cell _("selled total"), :style => 'red-cell'
          end
          table.row do |row|
            row.cell _("formula")
          end
          #table.row do |row|
          #  row.cell _("parcel totals"), :style => 'red-cell'
          #end
          #table.row do |row|
          #  row.cell _("formula")
          #end
        end # closes spreadsheet table
      end # closes spreadsheet
      [tmp_dir, report_file]
    end # closes def

    def report_orders_by_consumer(session)
      if session.blank? or session.orders.blank? or not defined? ::ODF::Spreadsheet 
        puts "there are no orders to show"
        return nil
      end 
      orders = session.orders

      tmp_dir = Dir.mktmpdir "noosfero-" 
      report_file = tmp_dir + '/report.ods'
      ::ODF::Spreadsheet.file report_file do |spreadsheet| 
        # create styles
        spreadsheet.style 'green-cell', :family => :cell do |style|
          style.property :text, 'font-weight' => 'bold', 'color' => '#00ff00'
        end
        spreadsheet.style 'blue-cell', :family => :cell do |style|
          style.property :text, 'font-weight' => 'bold', 'color' => '#0000ff'
        end
        spreadsheet.style 'red-cell', :family => :cell do |style|
          style.property :text, 'font-weight' => 'bold', 'color' => '#ff3010', 'background-color' => '#aaccbb'
        end
        spreadsheet.style 'larger-column', :family => :column do |style|
          style.property :column, 'column-width' => '200px'
        end
        # create sheet and populates
        spreadsheet.table _('Closed Orders') do |table|
          orders.each do |order|
            table.row do |row|
              row.cell _("Order code"), :style => 'blue-cell'
              row.cell _("Member name"), :style => 'blue-cell'
            end
            table.row do |row|
              row.cell order.id
              row.cell order.consumer.name
            end
            table.row do |row|
              row.cell _("Total Value"), :style => 'blue-cell'
              row.cell _("created"), :style => 'blue-cell'
              row.cell _("modified"), :style => 'blue-cell'
            end
            table.row do |row| # empty line
              row.cell order.total_price_asked
              row.cell order.created_at
              row.cell order.created_at
            end
            table.row do |row|
              row.cell _("product cod."), :style => 'green-cell'
              row.cell _("supplier"), :style => 'green-cell'
              row.cell _("product name"), :style => 'green-cell'
              row.cell _("qtt ordered"), :style => 'green-cell'
              row.cell  _("un."), :style => 'green-cell'
              row.cell _("price/un"), :style => 'green-cell'
              row.cell _("value"), :style => 'green-cell'
            end
            order.products.each do |ordered_product| 
              table.row do |row|
                row.cell ordered_product.product.id
                row.cell ordered_product.product.supplier.name
                row.cell ordered_product.product.name
                row.cell ordered_product.quantity_asked
                row.cell ordered_product.product.unit.singular
                row.cell ordered_product.product.price
                row.cell ordered_product.price_asked
              end 
            end # closes ordered_products.each
            table.row do |row|
              row.cell ""
              row.cell ""
              row.cell ""
            end
            table.row do |row|
              row.cell ""
              row.cell ""
              row.cell ""
            end
          end # closes ordered_products_by_supplier
        end # closes spreadsheet table
      end # closes spreadsheet
      [tmp_dir, report_file]
    end # closes def
  end
end


  #ActiveRecord::Base.extend Report::ClassMethods
