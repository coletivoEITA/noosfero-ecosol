module OrdersPlugin::Report

  protected

  def report_products_by_supplier products_by_suppliers
    p = Axlsx::Package.new
    wb = p.workbook

    # create styles
    redcell   = wb.styles.add_style :bg_color => "FF6633", :fg_color => "000000", :sz => 8, :b => true, :wrap_text => true, :alignment => { :horizontal=> :left }, :border => 0
    defaults = {:fg_color => "000000", :sz => 8, :alignment => { :horizontal=> :left, :vertical => :center, :wrap_text => false }, :border => 0}
    greencell = wb.styles.add_style(defaults.merge({:bg_color => "00AE00", :fg_color => "ffffff", :b => true }))
    bluecell  = wb.styles.add_style(defaults.merge({:bg_color => "99CCFF", :b => true}))
    default   = wb.styles.add_style(defaults.merge({:border => 0}))
    #bluecell_b_top  = wb.styles.add_style(defaults.merge({:bg_color => "99CCFF", :b => true, :border => {:style => :thin, :color => "FF000000", :edges => [:top]}}))
    #date  = wb.styles.add_style(defaults.merge({:format_code => t('lib.report.mm_dd_yy_hh_mm_am_pm')}))
    currency  = wb.styles.add_style(defaults.merge({:format_code => t('number.currency.format.xlsx_currency')}))
    #border_top = wb.styles.add_style :border => {:style => :thin, :color => "FF000000", :edges => [:top]}


    # supplier block start index (shifts on the loop for each supplier)
    sbs = 1
    # create sheet and populates
    wb.add_worksheet(:name => t('lib.report.products_report')) do |sheet|

      products_by_suppliers.each do |supplier, products, total_price_consumer_ordered|

        sheet.add_row [t('lib.report.supplier'),'',t('lib.report.phone'),'',t('lib.report.mail'),'','','','','',''], :style => bluecell
        sheet.merge_cells "A#{sbs}:B#{sbs}"

        # sp = index of the start of the products list / ep = index of the end of the products list
        sp = sbs + 4
        ep = sp + products.count - 1
        sheet.add_row [
          supplier.abbreviation_or_name, '', supplier.profile.contact_phone, '',supplier.profile.contact_email, '', '', '', '', '', ''], :style => default
          sbe = sbs+1
          ["A#{sbe}:B#{sbe}","C#{sbe}:D#{sbe}", "E#{sbe}:F#{sbe}"].each {|c| sheet.merge_cells c }

          sheet.add_row [''], :style => default # empty line

          sheet.add_row [
            t('lib.report.product_cod'), t('lib.report.product_name'), t('lib.report.qty_ordered'), t('lib.report.stock_qtt'), t('lib.report.min_stock'),
            t('lib.report.qtt_to_be_parcelled'),t('lib.report.projected_stock'), t('lib.report.un'), t('lib.report.price_un'), t('lib.report.selled_value'), t('lib.report.value_parcel')], :style => greencell

            # pl = product line
            pl = sp
            products.each do |product|

              sheet.add_row [
                product.id, product.name, product.total_quantity_consumer_ordered, 0, 0,
                "=IF(C#{pl}-D#{pl}+E#{pl}>0, C#{pl}-D#{pl}+E#{pl},0)", "=D#{pl}-C#{pl}+F#{pl}", (product.unit.singular rescue ''),
                product.price, product.total_price_consumer_ordered, "=F#{pl}*I#{pl}"], :style => [default,default,default,default,default,default,default,default,currency,currency,currency]

                pl +=1

            end # closes products.each

            sheet.add_row [""]
            sheet.add_row ["", '', '', '', '', '', t('lib.report.total_selled_value'), '', '',t('lib.report.total_parcel_value'), ''], :style =>bluecell
            row = ep +2
            ["G#{row}:H#{row}", "J#{row}:K#{row}"].each {|c| sheet.merge_cells c }
            row += 1
            ["G#{row}:H#{row}", "J#{row}:K#{row}"].each {|c| sheet.merge_cells c }
            sheet.add_row ["", '', '', '', '', '', "=SUM(J#{sp}:J#{ep})", '', '', "=SUM(k#{sp}:k#{ep})"]
            sheet.add_row [""]
            sbs = ep + 5

      end # closes products_by_suppliers
      sheet.add_row []
      sheet.rows.last.add_cell t('lib.report.selled_total'), :style => redcell
      sheet.rows.last.add_cell "=SUM(j1:j1000)", :style => default
      sheet.add_row []

      sheet.rows.last.add_cell t('lib.report.parcelled_total'), :style => redcell
      sheet.rows.last.add_cell "=SUM(K1:K1000)", :style => default
      sheet.column_widths 11,25,11,8,10,10,10,8,8,10,10

    end # closes spreadsheet

    tmp_dir = Dir.mktmpdir "noosfero-"
    report_file = tmp_dir + '/report.xlsx'

    p.serialize report_file
    [tmp_dir, report_file]
  end # closes def

  def report_orders_by_consumer orders
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

        sheet.add_row [t('lib.report.order_code'), t('lib.report.member_name'), '', t('lib.report.phone'), '', t('lib.report.mail'), ''], :style => bluecell_b_top
        ["B#{sbs}:C#{sbs}","D#{sbs}:E#{sbs}", "F#{sbs}:G#{sbs}"].each {|c| sheet.merge_cells c }

        sheet.add_row [order.code, order.consumer_data[:name], '',order.consumer_data[:contact_phone],'',order.consumer_data[:email],''], :style => default

        ["B#{sbs+1}:C#{sbs+1}","D#{sbs+1}:E#{sbs+1}", "F#{sbs+1}:G#{sbs+1}"].each {|c| sheet.merge_cells c }

        sheet.add_row [t('lib.report.created'), t('lib.report.modified'), '','', '','',''], :style => bluecell

        # sp = index of the start of the products list / ep = index of the end of the products list
        sp = sbs + 5
        ep = sp + order.items.count - 1
        sheet.add_row [order.created_at, order.updated_at, '', '', '', '','',''], :style => [date,date]

        sheet.add_row [t('lib.report.product_cod'), t('lib.report.supplier'), t('lib.report.product_name'),
                       t('lib.report.qty_ordered'),t('lib.report.un'),t('lib.report.price_un'), t('lib.report.value')], :style => greencell

        sbe = sp
        order.items.each do |item|

          sheet.add_row [item.product.id, item.product.supplier.abbreviation_or_name,
                         item.product.name, item.quantity_consumer_ordered,
                         (item.product.unit.singular rescue ''), item.product.price,
                         "=F#{sbe}*D#{sbe}"], :style => [default,default,default,default,default,currency,currency]

          sbe += 1
        end # closes order.products.each
        sheet.add_row ["", "", "", "","","",""], :style => border_top
        sheet.add_row ['','','','','',t('lib.report.total_value'),"=SUM(G#{sp}:G#{ep})"], :style => [default]*5+[bluecell,currency]
        sheet.add_row ["", "", "", "","","",""]
        sbs = sbe + 3
      end

      sheet.column_widths 15,30,30,9,6,8,10
    end # closes spreadsheet

    tmp_dir = Dir.mktmpdir "noosfero-"
    report_file = tmp_dir + '/report.xlsx'
    p.serialize report_file
    [tmp_dir, report_file]
  end # closes def

end

