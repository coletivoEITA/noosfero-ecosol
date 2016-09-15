module ProductsPlugin::Spreadsheet

  protected

  def products_spreadsheet products_by_supplier, name
    package = Axlsx::Package.new
    package.use_autowidth = true
    wb = package.workbook

    # create styles
    defaults   = {fg_color: "000000", sz: 8, alignment: { :horizontal=> :left, vertical: :center, wrap_text: false }, border: 0}
    bluecell   = wb.styles.add_style(defaults.merge({bg_color: "99CCFF", b: true}))
    default    = wb.styles.add_style(defaults.merge({border: 0}))
    currency   = wb.styles.add_style(defaults.merge({format_code: t('number.currency.format.xlsx_currency')}))
    centered   = wb.styles.add_style(alignment: { :horizontal=> :center, vertical: :center, wrap_text: false }, border: 0)

    # create sheet and populates
    wb.add_worksheet(name: t('lib.spreadsheet.products_spreadsheet')) do |sheet|

      title = t('lib.spreadsheet.spreadsheet_name') % {
          date: DateTime.now.strftime("%Y-%m-%d"), name: name}
      sheet.add_row [title, "","","","",""], style: centered
              sheet.merge_cells "A1:F1"
      sheet.add_row [t('lib.spreadsheet.supplier'),t('lib.spreadsheet.product_category'),t('lib.spreadsheet.product_cod'),t('lib.spreadsheet.product_name'),t('lib.spreadsheet.price'),t('lib.spreadsheet.unit')], style: bluecell
      products_by_supplier.each do |supplier, products|
        products.each do |product|
          unit = product.unit.present? ? product.unit.singular : ""
          sheet.add_row [supplier, product.product_category.name, product.id, product.name, product.price, unit], style: [default, default, default, default, currency, default]
        end
      end
    end # closes spreadsheet

    tmp_dir = Dir.mktmpdir "noosfero-"
    spreadsheet_file = tmp_dir + '/spreadsheet.xlsx'

    package.serialize spreadsheet_file
    spreadsheet_file
  end
end
