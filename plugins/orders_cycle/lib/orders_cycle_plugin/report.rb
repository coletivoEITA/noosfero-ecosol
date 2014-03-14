module OrdersCyclePlugin::Report

  module ClassMethods

    protected

    def report_products_by_supplier(cycle)
      items_by_supplier = cycle.items_by_suppliers

      if items_by_supplier.blank?
        return [nil, nil]
      end

      tmp_dir = Dir.mktmpdir "noosfero-"
      report_file = tmp_dir + '/report.xlsx'

      p = Axlsx::Package.new
      wb = p.workbook

      # create styles
      redcell   = wb.styles.add_style :bg_color => "FF6633", :fg_color => "000000", :sz => 8, :b => true, :wrap_text => true, :alignment => { :horizontal=> :left }, :border => 0
      defaults = {:fg_color => "000000", :sz => 8, :alignment => { :horizontal=> :left, :vertical => :center, :wrap_text => false }, :border => 0}
      greencell = wb.styles.add_style(defaults.merge({:bg_color => "00AE00", :fg_color => "ffffff", :b => true }))
      bluecell  = wb.styles.add_style(defaults.merge({:bg_color => "99CCFF", :b => true}))
      default   = wb.styles.add_style(defaults.merge({:border => 0}))
      bluecell_b_top  = wb.styles.add_style(defaults.merge({:bg_color => "99CCFF", :b => true, :border => {:style => :thin, :color => "FF000000", :edges => [:top]}}))
      date  = wb.styles.add_style(defaults.merge({:format_code => t('lib.report.mm_dd_yy_hh_mm_am_pm')}))
      currency  = wb.styles.add_style(defaults.merge({:format_code => t('number.currency.format.xlsx_currency')}))
      border_top = wb.styles.add_style :border => {:style => :thin, :color => "FF000000", :edges => [:top]}


      # supplier block start index (shifts on the loop for each supplier)
      sbs = 1
      # create sheet and populates
      wb.add_worksheet(:name => t('lib.report.products_report')) do |sheet|

        items_by_supplier.each do |supplier, items, total_price_asked, total_parcel_asked|

          sheet.add_row [t('lib.report.supplier'),'','','','','','','','','',''], :style => bluecell
          sheet.merge_cells "A#{sbs}:B#{sbs}"

          # sp = index of the start of the products list / ep = index of the end of the products list
          sp = sbs + 4
          ep = sp + items.count - 1
          sheet.add_row [
            supplier.abbreviation_or_name, '', '', '','', '', '', '', '', '', ''], :style => default
            sbe = sbs+1
          ["A#{sbe}:B#{sbe}","C#{sbe}:D#{sbe}", "E#{sbe}:F#{sbe}"].each {|c| sheet.merge_cells c }

          sheet.add_row [''], :style => default # empty line

          sheet.add_row [
            t('lib.report.min_stock'),
            t('lib.report.value_parcel')], :style => greencell

          # pl = product line
          pl = sp
          items.each do |item|

            sheet.add_row [
              item.id, item.name, item.total_quantity_asked, 0, 0,
              "=IF(C#{pl}-D#{pl}+E#{pl}>0, C#{pl}-D#{pl}+E#{pl},0)", "=D#{pl}-C#{pl}+F#{pl}", item.unit.singular,
              item.price, item.total_price_asked, "=F#{pl}*I#{pl}"], :style => [default,default,default,default,default,default,default,default,currency,currency,currency]

              pl +=1

          end # closes items.each

          sheet.add_row [""]
          sheet.add_row ["", '', '', '', '', '', t('lib.report.total_parcel_value'), ''], :style =>bluecell
          row = ep +2
          ["G#{row}:H#{row}", "J#{row}:K#{row}"].each {|c| sheet.merge_cells c }
          row += 1
          ["G#{row}:H#{row}", "J#{row}:K#{row}"].each {|c| sheet.merge_cells c }
          sheet.add_row ["", '', '', '', '', '', "=SUM(j#{sp}:j#{ep})", '', '', "=SUM(k#{sp}:k#{ep})"]
          sheet.add_row [""]
          sbs = ep + 5

        end # closes items_by_supplier
        sheet.add_row []
        sheet.rows.last.add_cell t('lib.report.selled_total'), :style => redcell
        sheet.rows.last.add_cell "=SUM(j1:j1000)", :style => default
        sheet.add_row []

        sheet.rows.last.add_cell t('lib.report.parcelled_total'), :style => redcell
        sheet.rows.last.add_cell "=SUM(K1:K1000)", :style => default
        sheet.column_widths 11,25,11,8,10,10,10,8,8,10,10

      end # closes spreadsheet
      p.serialize report_file
      [tmp_dir, report_file]
    end # closes def

    def report_orders_by_consumer(cycle)
      if cycle.blank? or cycle.orders.blank?
        puts "there are no orders to show"
        return nil
      end
      orders = cycle.orders.confirmed

      tmp_dir = Dir.mktmpdir "noosfero-"
      report_file = tmp_dir + '/report.xlsx'
      p = Axlsx::Package.new
      wb = p.workbook

      # create styles
      defaults = {:fg_color => "000000", :sz => 8, :alignment => { :horizontal=> :left, :vertical => :center, :wrap_text => true }, :border => 0}
      greencell = wb.styles.add_style(defaults.merge({:bg_color => "00AE00", :fg_color => "ffffff", :b => true }))
      bluecell  = wb.styles.add_style(defaults.merge({:bg_color => "99CCFF", :b => true}))
      default   = wb.styles.add_style(defaults.merge({:border => 0}))
      bluecell_b_top  = wb.styles.add_style(defaults.merge({:bg_color => "99CCFF", :b => true, :border => {:style => :thin, :color => "FF000000", :edges => [:top]}}))
      date  = wb.styles.add_style(defaults.merge({:format_code => t('lib.report.mm_dd_yy_hh_mm_am_pm')}))
      currency  = wb.styles.add_style(defaults.merge({:format_code => t('number.currency.format.xlsx_currency')}))
      border_top = wb.styles.add_style :border => {:style => :thin, :color => "FF000000", :edges => [:top]}

      # create sheet and populates
      wb.add_worksheet(:name => t('lib.report.closed_orders')) do |sheet|
        # supplier block start index (shifts on the loop for each supplier)
        sbs = 1
        orders.each do |order|

          sheet.add_row [t('lib.report.member_name'), '', '', '', '', ''], :style => bluecell_b_top
          sheet.merge_cells "B#{sbs}:C#{sbs}"

          sheet.add_row [order.code, order.consumer.name, '','','','',''], :style => default

          sheet.merge_cells "B#{sbs+1}:C#{sbs+1}"

          sheet.add_row [t('lib.report.modified'), '','', '','',''], :style => bluecell

          # sp = index of the start of the products list / ep = index of the end of the products list
          sp = sbs + 5
          ep = sp + order.items.count - 1
          sheet.add_row [order.created_at, order.updated_at, '', '', '', '','',''], :style => [date,date]

          sheet.add_row [t('lib.report.product_name'),
                         t('lib.report.value')], :style => greencell

          sbe = sp
          order.items.each do |item|

            sheet.add_row [item.product.id, item.product.supplier.abbreviation_or_name,
                           item.product.name, item.quantity_asked,
                           item.product.unit.singular, item.product.price,
                           "=F#{sbe}*D#{sbe}"], :style => [default,default,default,default,default,currency,currency]

            sbe += 1
          end # closes order.products.each
          sheet.add_row ["", "", "", "","","",""], :style => border_top
          sheet.add_row ['','','','','',t('lib.report.total_value'),"=SUM(G#{sp}:G#{ep})"], :style => [default]*5+[bluecell,currency]
          sheet.add_row ["", "", "", "","","",""]
          sbs = sbe + 3
        end # closes items_by_supplier
        sheet.column_widths 12,30,30,9,6,8,10
      end # closes spreadsheet
      p.serialize report_file
      [tmp_dir, report_file]
    end # closes def
  end
end

