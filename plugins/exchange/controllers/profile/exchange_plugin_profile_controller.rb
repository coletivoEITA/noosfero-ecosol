class ExchangePluginProfileController < ProfileController

 # skip_before_filter :login_required
 # before_filter :login_required #:only => [:activation_question, :accept_terms, :activate_enterprise]

  no_design_blocks

  def index
#     redirect_to :action => :create_proposal
  end

  def start_exchange
    @exchange = ExchangePlugin::Exchange.new
    @exchange.state = "proposal"
    @exchange.save!

    cross_exchange_enterprise = ExchangePlugin::ExchangeEnterprise.new
    cross_exchange_enterprise.enterprise_id = profile.id
    cross_exchange_enterprise.exchange_id = @exchange.id
    cross_exchange_enterprise.save

    cross_exchange_enterprise = ExchangePlugin::ExchangeEnterprise.new
    cross_exchange_enterprise.enterprise_id = @active_organization.id
    cross_exchange_enterprise.exchange_id = @exchange.id
    cross_exchange_enterprise.save
    
    @proposal = ExchangePlugin::Proposal.new
    @proposal.exchange_id = @exchange.id
    @proposal.state = "open"
    
    @target = profile
    @origin = @active_organization
 
    @proposal.exchange_id = @exchange.id
    @proposal.enterprise_origin_id = @origin.id
    @proposal.enterprise_target_id = @target.id
    @proposal.save!
        
    redirect_to :controller => "exchange_plugin_myprofile", :action => "exchange_console", :exchange_id => @exchange.id, :profile => @active_organization.identifier
  end

  
  def choose_target_offers
    #only registered users can access here
    @target_products = profile.products
    @enterprises = current_user.person.enterprises.find(:all, :conditions => ["profiles.id <> ?",profile.id])

    @target_knowledges = CmsLearningPluginLearning.all.select{|k| k.profile.id == profile.id}
  end




  def choose_origin_offers
    if request.post?
      if !(params[:target_product_id] || params[:target_knowledge_id])
        redirect_to :action => :choose_target_offers
        return
      end

      @origin_enterprise = Enterprise.find params[:origin_enterprise_id]
      @target_enterprise_name = profile.name

      if params[:target_product_id]
        @target_products = Product.find params[:target_product_id]
        @target_quantities = params[:target_quantity]
      end

      if params[:target_knowledge_id]
        @target_knowledges = CmsLearningPluginLearning.find params[:target_knowledge_id]
        @target_knowledge_quantities = params[:target_knowledge_quantity]
      end

      #offers
      @matching_products_inputs = (Product.products_inputs @origin_enterprise, profile)
      index_aux1 = @matching_products_inputs.collect{|m| m.products_supplier_id.to_i}
      @matching_products_interests = (Product.products_interests @origin_enterprise, profile)
      index_aux2 = @matching_products_interests.collect{|m| m.id.to_i}
      matching_products_index = index_aux1 + index_aux2

      @matching_knowledges_interests = (Article.knowledges_interests @origin_enterprise, profile)
      index_aux1 = @matching_knowledges_interests.collect{|m| m.id.to_i}
      @matching_knowledges_inputs = (Product.knowledges_inputs @origin_enterprise, profile)
      index_aux2 = @matching_knowledges_inputs.collect{|m| m.id.to_i}
      matching_knowledges_index = index_aux1 + index_aux2

      @origin_products_filtered = @origin_enterprise.products.reject{|p| matching_products_index.index(p.id)}
      @origin_knowledges_filtered = @origin_enterprise.articles.find(:all, :conditions => ["type = 'CmsLearningPluginLearning'"]).reject{|p| matching_knowledges_index.index(p.id)}

      #interests
      index_aux1 = @matching_products_inputs.collect{|m| m.input_category_id.to_i}
      index_aux2 = @matching_knowledges_inputs.collect{|m| m.input_cat.to_i}
      matching_inputs_index = index_aux1 + index_aux2
      @target_inputs_filtered = profile.inputs.reject{|i| matching_inputs_index.index(i.product_category_id)}

      index_aux1 = @matching_products_interests.collect{|m| m.opportunity_id.to_i}
      index_aux2 = @matching_knowledges_interests.collect{|m| m.interest_cat.to_i}
      matching_interests_index = index_aux1 + index_aux2

      target_interests = SnifferPluginOpportunity.all.select{|i| i.profile_id == ((SnifferPluginProfile.find_by_profile_id profile.id).id)}
      @target_interests_filtered = target_interests.reject{|i| matching_interests_index.index(i.opportunity_id)}
      @target_interests_names_filtered = @target_interests_filtered.collect{|i| (i.opportunity_type.constantize.find i.opportunity_id).name }

    end
  end

  def conclude_exchange_proposal

    if request.post?
      @origin_products = (params[:origin_product_id] ? (Product.find params[:origin_product_id]) : nil )
      @origin_quantities = params[:origin_quantity]
      @origin_knowledges = (params[:origin_knowledge_id] ? (CmsLearningPluginLearning.find params[:origin_knowledge_id]) : nil )
      @origin_knowledge_quantities = params[:origin_knowledge_quantity]
      @origin_enterprise = Enterprise.find params[:origin_enterprise_id]

      @target_enterprise_name = profile.name
      @target_products = (params[:target_product_id] ? (Product.find params[:target_product_id]) : nil)
      @target_quantities = params[:target_quantity]
      @target_knowledges = (params[:target_knowledge_id] ? (CmsLearningPluginLearning.find params[:target_knowledge_id]) : nil)
      @target_knowledge_quantities = params[:target_knowledge_quantity]
      @target_inputs = (params[:target_input_id] ? (Input.find params[:target_input_id]) : nil )
      @target_input_quantity = params[:target_input_quantity]

    end
  end

  def save_exchange
    @exchange = ExchangePlugin::Exchange.new
    @exchange.enterprise_origin = Enterprise.find params[:origin_enterprise_id]
    @exchange.enterprise_target = profile
    @exchange.state = "proposed"
    @exchange.simplified_state = "happening"
    @exchange.save!

    #message
    body = _('%{origin} proposed an exchange with %{target}: %{message}') % {:target => profile.name, :origin => @exchange.enterprise_origin.name, :message => params[:message]}
    m = ExchangePlugin::Message.new_exchange_message(@exchange, nil, nil, nil , body)

    if params[:target_product_id]
      params[:target_product_id].each do |p|
        element = ExchangePlugin::ExchangeElement.new
        element.element_id = p
        element.enterprise_id = profile.id
        element.element_type = "Product"
        element.quantity = params[:target_quantity][p.to_s]
        element.exchange_id = @exchange.id
        element.save!
      end
    end

    if params[:target_knowledge_id]
      params[:target_knowledge_id].each do |k|
        element = ExchangePlugin::ExchangeElement.new
        element.element_id = k
        element.enterprise_id = profile.id
        element.element_type = "CmsLearningPluginLearning"
        element.quantity = params[:target_knowledge_quantity][k.to_s]
        element.exchange_id = @exchange.id
        element.save!
      end
    end

    if params[:origin_product_id]
      params[:origin_product_id].each do |p|
        element = ExchangePlugin::ExchangeElement.new
        element.element_id = p
        element.enterprise_id = params[:origin_enterprise_id]
        element.element_type = "Product"
        element.quantity = params[:origin_quantity][p.to_s]
        element.exchange_id = @exchange.id
        element.save!
      end
    end

    if params[:origin_knowledge_id]
      params[:origin_knowledge_id].each do |k|
        element = ExchangePlugin::ExchangeElement.new
        element.element_id = k
        element.enterprise_id = params[:origin_enterprise_id]
        element.element_type = "CmsLearningPluginLearning"
        element.quantity = params[:origin_knowledge_quantity][k.to_s]
        element.exchange_id = @exchange.id
        element.save!
      end
    end

    #this should not be used; elements can only be products or knowledge
    #if params[:target_input_id]
    #  params[:target_input_id].each do |p|
    #    element = ExchangePlugin::ExchangeElement.new
    #    element.element_id = p
    #    element.enterprise_id = params[:origin_enterprise_id]
    #    element.element_type = "Input"
    #    element.quantity = params[:target_input_quantity][p.to_s]
    #    element.exchange_id = @exchange.id
    #    element.save!
    #  end
    #end

    redirect_to :controller => :exchange_plugin_myprofile, :action => :console, :profile => @exchange.enterprise_origin.identifier, :id => @exchange.id
  end
end
