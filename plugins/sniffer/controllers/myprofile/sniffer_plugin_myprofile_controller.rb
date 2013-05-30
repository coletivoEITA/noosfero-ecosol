class SnifferPluginMyprofileController < MyProfileController
  append_view_path File.join(File.dirname(__FILE__) + '/../views')
  helper CmsHelper

  protect 'edit_profile', :profile

  before_filter :fetch_sniffer_profile

  def edit
    if request.post?
      begin
        @sniffer_profile.update_attributes(params[:sniffer])
        @sniffer_profile.enabled = true
        @sniffer_profile.save!
        session[:notice] = @sniffer_profile.enabled ?
          _('Buyer interests published') : _('Buyer interests disabled')
      rescue Exception => exception
        flash[:error] = _('Could not save buyer interests options')
      end
      redirect_to :action => 'edit'
    end
  end

  def product_categories
    @categories = ProductCategory.find(:all, :limit => 20, :conditions => ["name ~* ?", params[:q]])
    respond_to do |format|
      format.html
      format.json { render :json => @categories.collect{ |i| {:id => i.id, :name => i.name} } }
    end
  end

  def search
    self.class.no_design_blocks

    @suppliers_products = @sniffer_profile.suppliers_products
    @buyers_products = @sniffer_profile.buyers_products
    @no_results = @suppliers_products.count == 0 && @buyers_products.count == 0

    @suppliers_hashes = build_products(@suppliers_products.collect(&:attributes))
    @buyers_hashes = build_products(@buyers_products.collect(&:attributes))

    suppliers = @suppliers_products.group_by{ |p| @id_profiles[p['profile_id'].to_i] }
    buyers = @buyers_products.group_by{ |p| @id_profiles[p['profile_id'].to_i] }
    buyers.each{ |k, v| suppliers[k] ||= [] }
    suppliers.each{ |k, v| buyers[k] ||= [] }
    @profiles = suppliers.merge!(buyers) do |profile, suppliers_products, buyers_products|
      {:suppliers_products => suppliers_products, :buyers_products => buyers_products}
    end
  end

  def map_balloon
    @profile = Profile.find params[:id]
    supplier_products = params[:suppliers_products] ? params[:suppliers_products].values : []
    buyer_products = params[:buyers_products] ? params[:buyers_products].values : []

    @suppliers_hashes = build_products(supplier_products).values.first
    @buyers_hashes = build_products(buyer_products).values.first

    render :layout => false
  end

  def my_map_balloon
    @enterprise = profile
    @inputs = @sniffer_profile.profile_input_categories
    @categories = @sniffer_profile.profile_product_categories
    @interests = @sniffer_profile.product_categories
    render :layout => false
  end

  protected

  def fetch_sniffer_profile
    @sniffer_profile = SnifferPluginProfile.find_or_create profile
  end

  def build_products(data)
    @id_profiles ||= {}
    @id_products ||= {}
    @id_categories ||= {}
    @id_my_products ||= {}
    @id_knowledges ||= {}

    return {} if data.blank?

    Profile.all(:conditions => {:id => data.map{ |h| h['profile_id'].to_i }.uniq}).each{ |p| @id_profiles[p.id] ||= p }
    Product.all(:conditions => {:id => data.map{ |h| h['id'].to_i }.uniq}, :include => :enterprise).each{ |p| @id_products[p.id] ||= p }
    ProductCategory.all(:conditions => {:id => data.map{ |h| h['product_category_id'].to_i }.uniq}).each{ |c| @id_categories[c.id] ||= c }
    Product.all(:conditions => {:id => data.map{ |h| h['my_product_id'].to_i }.uniq}, :include => :enterprise).each{ |p| @id_my_products[p.id] ||= p }
    Article.all(:conditions => {:id => data.map{|h| h['knowledge_id'].to_i}.uniq}).each{ |k| @id_knowledges[k.id] ||= k}

    results = {}
    data.each do |attributes|
      profile = @id_profiles[attributes['profile_id'].to_i]
      profile.distance = attributes['profile_distance']

      results[profile] ||= []
      results[profile] << {
        :profile => profile, :partial => attributes['view'], :product => @id_products[attributes['id'].to_i],
        :category => @id_categories[attributes['product_category_id'].to_i],
        :my_product => @id_my_products[attributes['my_product_id'].to_i], :partial => attributes['view'],
        :knowledge => @id_knowledges[attributes['knowledge_id'].to_i], :partial => attributes['view'],
      }
    end
    results
  end

end

# monkey patch old rails bug
ActiveSupport::OrderedHash.class_eval do 
  def merge!(other_hash)
    if block_given?
      other_hash.each { |k, v| self[k] = key?(k) ? yield(k, self[k], v) : v }
    else
      other_hash.each { |k, v| self[k] = v }
    end
    self
  end
end

