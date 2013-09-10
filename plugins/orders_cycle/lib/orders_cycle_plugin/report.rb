module OrdersCyclePlugin::Report

  module ClassMethods

    def report_products_by_supplier(cycle)
      ordered_products_by_supplier = cycle.ordered_products_by_suppliers

      if ordered_products_by_supplier.blank?
        return [nil, nil]
      end

      tmp_dir = Dir.mktmpdir "noosfero-"
      report_file = tmp_dir + '/report.xlsx'

      p = Axlsx::Package.new
      wb = p.workbook

      # create styles
      greencell = wb.styles.add_style :bg_color => "00AE00", :fg_color => "ffffff", :sz => 8, :b => true, :wrap_text => true, :alignment => { :horizontal=> :left }, :border => 0
      bluecell  = wb.styles.add_style :bg_color => "99CCFF", :fg_color => "000000", :sz => 8, :b => true, :wrap_text => true, :alignment => { :horizontal=> :left }, :border => 0
      redcell   = wb.styles.add_style :bg_color => "FF6633", :fg_color => "000000", :sz => 8, :b => true, :wrap_text => true, :alignment => { :horizontal=> :left }, :border => 0
      default   = wb.styles.add_style :fg_color => "000000", :sz => 8, :wrap_text => true, :alignment => { :horizontal=> :left }, :border => 0


      # supplier block start index (shifts on the loop for each supplier)
      sbs = 1
      # create sheet and populates
      wb.add_worksheet(:name => I18n.t('orders_cycle_plugin.lib.report.products_report')) do |sheet|

        ordered_products_by_supplier.each do |supplier, ordered_products, total_price_asked, total_parcel_asked|

          sheet.add_row [I18n.t('orders_cycle_plugin.lib.report.supplier'),'', I18n.t('orders_cycle_plugin.lib.report.total_selled_value'), '',I18n.t('orders_cycle_plugin.lib.report.total_parcel_value'), '','','','','',''], :style => bluecell

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
            I18n.t('orders_cycle_plugin.lib.report.product_cod'), I18n.t('orders_cycle_plugin.lib.report.product_name'), I18n.t('orders_cycle_plugin.lib.report.qty_ordered'), I18n.t('orders_cycle_plugin.lib.report.stock_qtt'), I18n.t('orders_cycle_plugin.lib.report.min_stock'),
            I18n.t('orders_cycle_plugin.lib.report.qtt_to_be_parcelled'),I18n.t('orders_cycle_plugin.lib.report.projected_stock'), I18n.t('orders_cycle_plugin.lib.report.un'), I18n.t('orders_cycle_plugin.lib.report.price_un'), I18n.t('orders_cycle_plugin.lib.report.selled_value'), I18n.t('orders_cycle_plugin.lib.report.value_parcel')], :style => greencell

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
          sheet.rows[0].add_cell I18n.t('orders_cycle_plugin.lib.report.selled_total'), :style => redcell
          sheet.rows[1].add_cell ''
          sheet.rows[1].add_cell "=SUM(j1:j1000)", :style => default

          sheet.rows[2].add_cell ''
          sheet.rows[2].add_cell I18n.t('orders_cycle_plugin.lib.report.parcelled_total'), :style => redcell
          sheet.rows[3].add_cell ''
          sheet.rows[3].add_cell "=SUM(K1:K1000)", :style => default
        sheet.column_widths 8,25,8,8,10,10,10,8,8,10,10

      end # closes spreadsheet
      p.serialize report_file
      [tmp_dir, report_file]
    end # closes def

    def report_orders_by_consumer(cycle)
      if cycle.blank? or cycle.orders.blank?
        puts "there are no orders to show"
        return nil
      end
      orders = cycle.orders

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
      date  = wb.styles.add_style(defaults.merge({:format_code => I18n.t('orders_cycle_plugin.lib.report.mm_dd_yy_hh_mm_am_pm')}))
      currency  = wb.styles.add_style(defaults.merge({:format_code => t('number.currency.format.xlsx_currency')}))
      border_top = wb.styles.add_style :border => {:style => :thin, :color => "FF000000", :edges => [:top]}

      # create sheet and populates
      wb.add_worksheet(:name => I18n.t('orders_cycle_plugin.lib.report.closed_orders')) do |sheet|
        # supplier block start index (shifts on the loop for each supplier)
        sbs = 1
        orders.each do |order|

          sheet.add_row [I18n.t('orders_cycle_plugin.lib.report.order_code'), I18n.t('orders_cycle_plugin.lib.report.member_name'), '', '', '', '', ''], :style => bluecell_b_top
          sheet.merge_cells "B#{sbs}:C#{sbs}"

          sheet.add_row [order.id, order.consumer.name, '','','','',''], :style => default

          sheet.merge_cells "B#{sbs+1}:C#{sbs+1}"

          sheet.add_row [I18n.t('orders_cycle_plugin.lib.report.total_value'),I18n.t('orders_cycle_plugin.lib.report.created'), I18n.t('orders_cycle_plugin.lib.report.modified'), '','', '',''], :style => bluecell

          # sp = index of the start of the products list / ep = index of the end of the products list
          sp = sbs + 5
          ep = sp + order.products.count - 1
          sheet.add_row ["=SUM(G#{sp}:G#{ep})", order.created_at, order.updated_at, '', '', '', '',''], :style => [currency,date,date]

          sheet.add_row [I18n.t('orders_cycle_plugin.lib.report.product_cod'), I18n.t('orders_cycle_plugin.lib.report.supplier'), I18n.t('orders_cycle_plugin.lib.report.product_name'),
                         I18n.t('orders_cycle_plugin.lib.report.qty_ordered'),I18n.t('orders_cycle_plugin.lib.report.un'),I18n.t('orders_cycle_plugin.lib.report.price_un'), I18n.t('orders_cycle_plugin.lib.report.value')], :style => greencell

          sbe = sp
          order.products.each do |op|

            sheet.add_row [op.product.id, op.product.supplier.abbreviation_or_name,
                           op.product.name, op.quantity_asked,
                           op.product.unit.singular, op.product.price,
                           "=F#{sbe}*D#{sbe}"], :style => [default,default,default,default,default,currency,currency]

            sbe += 1
          end # closes order.products.each
          sheet.add_row ["", "", "", "","","",""], :style => border_top
          sheet.add_row ["", "", "", "","","",""]
          sbs = sbe + 2
        end # closes ordered_products_by_supplier
        sheet.column_widths 12,30,30,9,6,8,10
      end # closes spreadsheet
      p.serialize report_file
      [tmp_dir, report_file]
    end # closes def
  end
end

