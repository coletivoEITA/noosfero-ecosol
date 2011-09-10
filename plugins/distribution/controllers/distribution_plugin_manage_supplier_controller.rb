class DistributionPluginManageSupplierController < DistributionPluginMyprofileController
  no_design_blocks

  helper ApplicationHelper

  def new
    @supplier = DistributionPluginNode.new :role => 'supplier'
    @profile = Enterprise.new :visible => false, :environment => profile.environment
    if params[:name]
      DistributionPluginNode.transaction do
        Profile.transaction do
          begin
            @profile.identifier = Digest::MD5.hexdigest(rand.to_s)
          end while not Profile.find_by_identifier(@profile.identifier).blank?
          @profile.name = params[:name]
          @profile.save!
          profile.admins.each { |a| @profile.add_admin(a) }

          @supplier.profile = @profile
          @supplier.save!
          @supplier.add_consumer @node

          render :update do |page|
            page << "window.location.reload()"
          end
        end
      end
    else
      render :layout => false
    end
  end

  def add
  end

  def destroy
    @supplier = DistributionPluginNode.find params[:id]
    @supplier.remove_consumer @node
    if @supplier.dummy?
      @supplier.profile.destroy
      @supplier.destroy
    end

    render :update do |page|
      page << "window.location.reload()"
    end
  end
end
