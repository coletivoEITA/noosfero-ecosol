class SnifferPluginMyprofileController < MyProfileController
  
  include SnifferPlugin::Helper
  
  before_filter :fetch_sniffer_profile, :only => [:edit, :search]

  helper CmsHelper
  helper_method :profile_hash

  def edit
    if request.post?
      begin
        @sniffer_profile.update_attributes(params[:sniffer_plugin_profile])
        @sniffer_profile.enabled = true
        @sniffer_profile.save!
        session[:notice] = _('Consumer interests updated')
      rescue Exception => exception
        flash[:error] = _('Could not save consumer interests')
      end
    end
  end

  def product_categories
    scope = environment.categories.where("type = 'ProductCategory'")
    @categories = find_by_contents(:product_categories, @profile, scope, params[:q], {:per_page => 10, :page => 1})[:results]

    render :json => @categories.map{ |i| {:id => i.id, :name => i.name} }
  end

  def product_category_search
    scope = environment.categories.where("type = 'ProductCategory'")
    @categories = find_by_contents(:product_categories, @profile, scope, params[:term], {:per_page => 10, :page => 1})[:results]

    render :json => @categories.map{ |pc| {:value => pc.id, :label => pc.name} }
  end

  def product_category_add
    @product_category = environment.categories.find params[:id]
    response = { :productCategory => {
        :id   => @product_category.id,
        :name => @product_category.name,
        :fullName => @product_category.full_name(' &rarr; '),
        :url  => url_for(Noosfero.url_options.merge({
          :controller => 'search',
          :action => 'category_index',
          :category_path => @product_category.path.split('/'),
          :host => @product_category.environment.default_hostname
        }))
      }
    }
    response[:enterprises] = @product_category.sniffer_plugin_enterprises.map do |enterprise|
      profile_data = profile_hash(enterprise)
      profile_data[:balloonUrl] = url_for :controller => :sniffer_plugin_myprofile, :action => :map_balloon, :id => enterprise[:id], :escape => false
      profile_data[:sniffer_plugin_distance] = distance_between_profiles(@profile, enterprise)
      profile_data[:suppliersProducts] = suppliers_products_hash(
        enterprise.products.sniffer_plugin_products_from_category(@product_category)
      )
      profile_data[:consumersProducts] = []
      profile_data
    end
    render :text => response.to_json
  end

  def search
    self.class.no_design_blocks

    @suppliers_products = @sniffer_profile.suppliers_products
    @consumers_products = @sniffer_profile.consumers_products
    @no_results = @suppliers_products.count == 0 and @consumers_products.count == 0

    profiles_of_interest = fetch_profiles(@suppliers_products + @consumers_products)

    @suppliers_categories = @suppliers_products.collect(&:product_category)
    @consumers_categories = @consumers_products.collect(&:product_category)
    @categories = (@suppliers_categories + @consumers_categories).sort_by(&:name).uniq

    suppliers = @suppliers_products.group_by{ |p| p['profile_id'].to_i }
    consumers = @consumers_products.group_by{ |p| p['profile_id'].to_i }

    @profiles_data = {}
    suppliers.each do |id, products|
      @profiles_data[id] = {
        :profile => profiles_of_interest[id],
        :suppliers_products => suppliers_products_hash(products),
        :consumers_products => []
      }
    end
    consumers.each do |id, products|
      @profiles_data[id] ||= { :profile => profiles_of_interest[id] }
      @profiles_data[id][:suppliers_products] ||= []
      @profiles_data[id][:consumers_products] = consumers_products_hash(products)
    end
  end

  def map_balloon
    @profile_of_interest = Profile.find params[:id]
    @categories = @profile_of_interest.categories

    suppliers_products = params[:suppliersProducts].blank? ? [] : params[:suppliersProducts].values
    consumers_products = params[:consumersProducts].blank? ? [] : params[:consumersProducts].values
    @empty = suppliers_products.empty? && consumers_products.empty?
    @has_both = !suppliers_products.blank? && !consumers_products.blank?

    @suppliers_hashes = build_products(suppliers_products).values.first
    @consumers_hashes = build_products(consumers_products).values.first

    render :layout => false
  end

  def my_map_balloon
    @categories = @profile.categories
    render :layout => false
  end

  protected

  def fetch_sniffer_profile
    @sniffer_profile = SnifferPlugin::Profile.find_or_create profile
  end

  def profile_hash(profile)
    profile_hash = {}
    visible_attributes = [:id, :name, :lat, :lng, :sniffer_plugin_distance]
    visible_attributes.each{ |a| profile_hash[a] = profile[a] || 0 }
    profile_hash
  end

  def suppliers_products_hash(products)
    visible_attributes = [:id, :profile_id, :product_category_id, :view, :knowledge_id]
    products.map do |product|
      suppliers_hash = {}
      visible_attributes.each{ |a| suppliers_hash[a] = product[a] }
      suppliers_hash
    end
  end

  def consumers_products_hash(products)
    visible_attributes = [:id, :profile_id, :product_category_id, :view, :my_product_id, :knowledge_id]
    products.map do |product|
      consumers_hash = {}
      visible_attributes.each{ |a| consumers_hash[a] = product[a] }
      consumers_hash
    end
  end

  def fetch_profiles(products)
    profiles = Profile.all :conditions => {:id => products.map { |p| p['profile_id'] }}
    profiles_hash = {}
    profiles.each do |p|
      p[:sniffer_plugin_distance] = distance_between_profiles(@profile, p)
      profiles_hash[p.id] ||= p
    end
    profiles_hash
  end

  def build_products(data)
    id_products, id_my_products, id_knowledges = {}, {}, {}

    results = {}
    return results if data.blank?

    grab_id = proc{ |field| data.map{ |h| h[field].to_i }.uniq }

    id_profiles = fetch_profiles(data)

    products = Product.all :conditions => {:id => grab_id.call('id')}, :include => [:enterprise, :product_category]
    products.each{ |p| id_products[p.id] ||= p }
    my_products = Product.all :conditions => {:id => grab_id.call('my_product_id')}, :include => [:enterprise, :product_category]
    my_products.each{ |p| id_my_products[p.id] ||= p }
    knowledges = Article.all :conditions => {:id => grab_id.call('knowledge_id')}
    knowledges.each{ |k| id_knowledges[k.id] ||= k}

    data.each do |attributes|
      profile = id_profiles[attributes['profile_id'].to_i]

      results[profile.id] ||= []
      results[profile.id] << {
        :partial => attributes['view'],
        :product => id_products[attributes['id'].to_i],
        :my_product => id_my_products[attributes['my_product_id'].to_i],
        :knowledge => id_knowledges[attributes['knowledge_id'].to_i]
      }
    end
    results
  end

end
