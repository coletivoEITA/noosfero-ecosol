module FinancialPlugin::Report

  protected

  def cycle_report cycle
    p = Axlsx::Package.new
    p.use_autowidth = true
    wb = p.workbook

    # create styles
    defaults   = {fg_color: "000000", sz: 8, alignment: { :horizontal=> :left, vertical: :center, wrap_text: false }, border: 0}
    default    = wb.styles.add_style(defaults.merge({border: 0}))
    big        = wb.styles.add_style(defaults.merge({sz: 15, b: true, alignment: {horizontal: :center},border: {style: :thin, color: "FF000000", edges: [:top]}}))
    blue       = wb.styles.add_style(defaults.merge({bg_color: "99CCFF", b: true}))
    currency   = wb.styles.add_style(defaults.merge({format_code: t('number.currency.format.xlsx_currency')}))
    datetime   = wb.styles.add_style(defaults.merge({format_code: t('lib.report.mm_dd_yy_hh_mm_am_pm')}))
    border_top = wb.styles.add_style(defaults.merge({border: {style: :thin, color: "FF000000", edges: [:top]}}))

    wb.add_worksheet(name: t('financial_plugin.lib.report.revenue_totalization')) do |sheet|
      total = 0
      sheet.add_row [t("orders_plugin.views.admin.financial.type"), t("orders_plugin.views.admin.financial.value"),t("orders_plugin.views.admin.financial.date"), t("orders_plugin.views.admin.financial.description")], style: blue
      [:income, :payment].each do |c|
        cycle.transactions_for_report[c].each do |transaction|
          total += transaction.value
          desc = transaction.payment.nil? ? transaction.description : transaction.payment.description
          sheet.add_row [t("orders_plugin.views.admin.financial."+c.to_s), transaction.value.to_s, transaction.created_at.strftime(I18n.t('orders_plugin.lib.date_helper.m_d_y_hh_m')) ,desc], style: [default, currency, datetime, default]
        end
      end
      sheet.add_row [""], style: default
      sheet.add_row [t("orders_plugin.views.admin.financial.total"), total], style: [blue, currency]
      sheet.add_row ["", "", "", ""], style: border_top

      sheet.column_widths 20,15,20,20,20
    end


    wb.add_worksheet(name: t('financial_plugin.lib.report.cash_totalization')) do |sheet|
      sheet.add_row [t("orders_plugin.views.admin.financial.expense")], style: big
      sheet.merge_cells("A1:D1")
      row= 2 # next empty row

      total = 0
      sheet.add_row [t("orders_plugin.views.admin.financial.value"),t("orders_plugin.views.admin.financial.date"), t("orders_plugin.views.admin.financial.responsible"), t("orders_plugin.views.admin.financial.description")], style: blue
      row += 1
      cycle.transactions_for_report[:expense].each do |transaction|
        total += transaction.value
        sheet.add_row [transaction.value.to_s, transaction.created_at.strftime(I18n.t('orders_plugin.lib.date_helper.m_d_y_hh_m')), transaction.operator.name,transaction.description], style: [currency, datetime, default, default]
        row += 1
      end

      sheet.add_row [""], style: default
      sheet.add_row [t("orders_plugin.views.admin.financial.total"), total], style: [blue, currency]

      sheet.add_row ["", "", "", ""], style: border_top
      row +=3

      sheet.add_row [t("orders_plugin.views.admin.financial.payment")], style: big
      sheet.merge_cells("A#{row}:D#{row}")

      total = 0
      sheet.add_row [t("orders_plugin.views.admin.financial.value"),t("orders_plugin.views.admin.financial.date"), t("orders_plugin.views.admin.financial.responsible"), t("orders_plugin.views.admin.financial.payment_method")], style: blue
      cycle.transactions_for_report[:payment].each do |transaction|
        total += transaction.value
        sheet.add_row [transaction.value.to_s, transaction.created_at.strftime(I18n.t('orders_plugin.lib.date_helper.m_d_y_hh_m')), transaction.operator.name, I18n.t("payments_plugin.models.payment_methods."+transaction.payment_method.slug)], style: [currency, datetime, default, default]
      end

      sheet.add_row [""], style: default
      sheet.add_row [t("orders_plugin.views.admin.financial.total"), total], style: [blue, currency]
      sheet.add_row ["", "", "", ""], style: border_top

      sheet.column_widths 15,20,20,20,20
    end

    tmp_dir = Dir.mktmpdir "noosfero-"
    report_file = tmp_dir + '/report.xlsx'

    p.serialize report_file
    report_file
  end
end

