module DistributionPlugin::Report
  module ClassMethods
    def report_products_by_supplier(session)
      ordered_products_by_supplier = session.ordered_products_by_suppliers

      if ordered_products_by_supplier.blank?
        return [nil, nil]
      end

      tmp_dir = Dir.mktmpdir "noosfero-"
      report_file = tmp_dir + '/report.xlsx'

      p = Axlsx::Package.new
      wb = p.workbook

      # create styles
      # todo: make font-weight: bold on the next 3
      greencell = wb.styles.add_style :bg_color => "00AE00", :fg_color => "ffffff", :sz => 8, :b => true, :wrap_text => true, :alignment => { :horizontal=> :left }, :border => 0
      bluecell  = wb.styles.add_style :bg_color => "99CCFF", :fg_color => "000000", :sz => 8, :b => true, :wrap_text => true, :alignment => { :horizontal=> :left }, :border => 0
      redcell   = wb.styles.add_style :bg_color => "FF6633", :fg_color => "000000", :sz => 8, :b => true, :wrap_text => true, :alignment => { :horizontal=> :left }, :border => 0
      default   = wb.styles.add_style :fg_color => "000000", :sz => 8, :wrap_text => true, :alignment => { :horizontal=> :left }, :border => 0


      # supplier block start index (shifts on the loop for each supplier)
      sbs = 1
      # create sheet and populates
      wb.add_worksheet(:name => _("products report")) do |sheet|

        ordered_products_by_supplier.each do |supplier, ordered_products, total_price_asked, total_parcel_asked|

          sheet.add_row [_("Supplier"),'', _("Total selled value"), '',_('Total parcel value'), '','','','','',''], :style => bluecell

          ["A#{sbs}:B#{sbs}","C#{sbs}:D#{sbs}", "E#{sbs}:F#{sbs}"].each {|c| sheet.merge_cells c }

          # sp = index of the start of the products list / ep = index of the end of the products list
          sp = sbs + 4
          ep = sp + ordered_products.count - 1
          sheet.add_row [
            supplier.name, '',
            "=SUM(j#{sp}:j#{ep})", '',
            "=SUM(k#{sp}:k#{ep})", '', '', '', '', '', ''], :style => default
            sbe = sbs+1
          ["A#{sbe}:B#{sbe}","C#{sbe}:D#{sbe}", "E#{sbe}:F#{sbe}"].each {|c| sheet.merge_cells c }

          sheet.add_row ['', '', '', '', '', '', '', '', '', '', ''], :style => default # empty line

          sheet.add_row [
            _("product cod."), _("product name"), _("qty ordered"), _('stock qtt'), _("min. stock"),
            _('qtt to be parcelled'),_('projected stock'), _("un."), _("price/un"), _("selled value"), _('value parcel')], :style => greencell

          # pl = product line
          pl = sp
          ordered_products.each do |ordered_product|

            sheet.add_row [
              ordered_product.id, ordered_product.name, ordered_product.total_quantity_asked, 0, 0,
              "=IF(C#{pl}-D#{pl}+E#{pl}>0, C#{pl}-D#{pl}+E#{pl},0)", "=D#{pl}-C#{pl}+F#{pl}", ordered_product.unit.singular,
              ordered_product.price, ordered_product.total_price_asked, "=F#{pl}*I#{pl}"], :style => default

              pl +=1

          end # closes ordered_products.each

          sheet.add_row [""]
          sbs = ep + 2

        end # closes ordered_products_by_supplier
          sheet.rows[0].add_cell ''
          sheet.rows[0].add_cell _("selled total"), :style => redcell
          sheet.rows[1].add_cell ''
          sheet.rows[1].add_cell "=SUM(j1:j1000)", :style => default

          sheet.rows[2].add_cell ''
          sheet.rows[2].add_cell _("Parcelled total"), :style => redcell
          sheet.rows[3].add_cell ''
          sheet.rows[3].add_cell "=SUM(K1:K1000)", :style => default
        sheet.column_widths 8,25,8,8,10,10,10,8,8,10,10

      end # closes spreadsheet
      p.serialize report_file
      [tmp_dir, report_file]
    end # closes def

    def report_orders_by_consumer(session)
      if session.blank? or session.orders.blank?
        puts "there are no orders to show"
        return nil
      end
      orders = session.orders

      tmp_dir = Dir.mktmpdir "noosfero-"
      report_file = tmp_dir + '/report.xlsx'
      p = Axlsx::Package.new
      wb = p.workbook
      # create styles
      # todo: make font-weight: bold on the next 3
      greencell = wb.styles.add_style :bg_color => "ffffff", :fg_color => "00FF00", :sz => 14, :b => true, :alignment => { :horizontal=> :center }
      bluecell  = wb.styles.add_style :bg_color => "ffffff", :fg_color => "0000FF", :sz => 14, :b => true, :alignment => { :horizontal=> :center }
      redcell   = wb.styles.add_style :bg_color => "aaccbb", :fg_color => "FF0000", :sz => 14, :b => true, :alignment => { :horizontal=> :center }
      # create sheet and populates
      wb.add_worksheet(:name => _("Closed Orders")) do |sheet|
        orders.each do |order|

          sheet.add_row [_("Order code"), _("Member name")], :style => bluecell

          sheet.add_row [order.id, order.consumer.name]

          sheet.add_row [_("Total Value"),_("created"), _("modified")], :style => bluecell

          sheet.add_row [order.total_price_asked, order.created_at, order.created_at]

          sheet.add_row [_("product cod."), _("supplier"), _("product name"), _("qty ordered"),_("price/un."),  _("value")], :style => greencell

          order.products.each do |ordered_product|

            sheet.add_row [ordered_product.product.id, ordered_product.product.supplier.name,
                           ordered_product.product.name, ordered_product.quantity_asked,
                           ordered_product.product.unit.singular, ordered_product.product.price, ordered_product.price_asked]

          end # closes ordered_products.each
          sheet.add_row ["", "", ""]
          sheet.add_row ["", "", ""]
        end # closes ordered_products_by_supplier
      end # closes spreadsheet
      p.serialize report_file
      [tmp_dir, report_file]
    end # closes def
  end
end


  #ActiveRecord::Base.extend Report::ClassMethods
