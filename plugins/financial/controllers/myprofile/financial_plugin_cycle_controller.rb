class FinancialPluginCycleController < MyProfileController

  include FinancialPlugin::Report

  def report_cycle
    @cycle = OrdersCyclePlugin::Cycle.find params[:id]
    report_file = cycle_report @cycle

    send_file report_file, type: 'application/xlsx',
      disposition: 'attachment',
      filename: t('financial_plugin.controllers.myprofile.cycle.cycle_report') % {
        date: DateTime.now.strftime("%Y-%m-%d"), profile_identifier: profile.identifier, name: @cycle.name}
  end

  def create
    @transaction = FinancialPlugin::Transaction.new(params.require(:transaction).permit(:description, :value, :direction))
    @cycle = OrdersCyclePlugin::Cycle.where(id: params[:transaction][:cycle_id]).first
    @transaction.target = @cycle
    @transaction.target_profile = @cycle.profile if @cycle
    @transaction.operator_id = user.id
    @transaction.date = Time.now

    @transaction.save
  end
end
