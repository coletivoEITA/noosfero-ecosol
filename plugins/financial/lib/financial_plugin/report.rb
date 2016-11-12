module FinancialPlugin::Report

  protected

  def cycle_report cycle
    p = Axlsx::Package.new
    p.use_autowidth = true
    wb = p.workbook

    # create styles
    defaults   = {fg_color: "000000", sz: 8, alignment: { :horizontal=> :left, vertical: :center, wrap_text: false }, border: 0}
    default    = wb.styles.add_style(defaults.merge({border: 0}))
    currency   = wb.styles.add_style(defaults.merge({format_code: t('number.currency.format.xlsx_currency')}))

    wb.add_worksheet(name: t('financial_plugin.lib.report.cash_totalization')) do |sheet|
      sheet.add_row ["", "","row"], style: default
    end
    wb.add_worksheet(name: t('financial_plugin.lib.report.revenue_totalization')) do |sheet|
      sheet.add_row ["", "","12"], style: currency
    end

    tmp_dir = Dir.mktmpdir "noosfero-"
    report_file = tmp_dir + '/report.xlsx'

    p.serialize report_file
    report_file
  end
end

