class DistributionPluginOrderedProductController < DistributionPluginMyprofileController
  no_design_blocks

  def new
    @order = DistributionPluginOrder.find params[:order_id]
    @session_product = DistributionPluginProduct.find params[:session_product_id]
    @quantity_asked = params[:quantity_asked] || 1

    @ordered_product = DistributionPluginOrderedProduct.find_by_order_id_and_session_product_id(@order.id, @session_product.id)
    if @ordered_product.nil?
      @ordered_product = DistributionPluginOrderedProduct.create!(:order_id => @order.id, :session_product_id => @session_product.id, :quantity_asked => @quantity_asked)
    end
  end

  def edit
    @ordered_product = DistributionPluginOrderedProduct.find params[:id]
    @order = @ordered_product.order
    @ordered_product.update_attributes params[:ordered_product]
  end

  def report_products
    extend DistributionPlugin::Report::ClassMethods
    session = DistributionPluginSession.find_by_id(params[:id])
    @ordered_products_by_suppliers = session.ordered_products_by_suppliers
    tmp_dir, report_file = report_products_by_supplier @ordered_products_by_suppliers
    if report_file.nil?
      return false
    end
    send_file report_file, :type => 'application/ods',
      :disposition => 'attachment',
      :filename => _("Products Report.ods")
    require 'fileutils'
    #FileUtils.rm_rf tmp_dir
  end

  def destroy
    p = DistributionPluginOrderedProduct.find params[:id]
    @ordered_product = p
    @order = p.order
    p.destroy if p
  end

end
