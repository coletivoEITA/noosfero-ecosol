class ExchangePluginMyprofileController < MyProfileController
  no_design_blocks
  protect 'edit_profile', :profile

  helper ExchangePlugin::ExchangeDisplayHelper
  helper_method :sort_column, :sort_direction

  def index

   @exchanges_enterprise = ExchangePlugin::ExchangeEnterprise.all.select{|ex| ex.enterprise_id == profile.id}
   
   @active_exchanges_enterprise = @exchanges_enterprise.select{|ex| ((ex.exchange.state != "concluded") && (ex.exchange.state != "cancelled"))}
   
   @inactive_exchanges_enterprise = @exchanges_enterprise.select{|ex| ((ex.exchange.state == "concluded") || (ex.exchange.state == "cancelled"))}
   
  end
  
  def exchange_console
    @exchange = ExchangePlugin::Exchange.find params[:exchange_id]

    @proposals = @exchange.proposals.all(:order => "created_at desc")
    @proposal = @proposals.first

    @target = @proposal.enterprise_target
    @origin = @proposal.enterprise_origin
    @theother = @exchange.enterprises.find(:first, :conditions => ["enterprise_id != ?",profile.id])

    @theother_knowledges = CmsLearningPluginLearning.all.select{|k| k.profile.id == @theother.id} - @proposal.knowledges
    @profile_knowledges = CmsLearningPluginLearning.all.select{|k| k.profile.id == @profile.id} - @proposal.knowledges

    @profile_products = @profile.products - @proposal.products
    @theother_products = @theother.products - @proposal.products 
    
    @exchange_happened_array = [["Sim",0],["Parcialmente (fizemos nossa parte, o outro lado não)",1],
     ["Parcialmente (fizemos nossa parte, o outro lado não)",2],["Não",3]]

  end
  
  def add_unregistered_item
    unreg_item = ExchangePlugin::UnregisteredItem.new
    unreg_item.name = params[:name]
    unreg_item.description = params[:description]
    unreg_item.save!
    
    add_element_helper(unreg_item.id, "ExchangePlugin::UnregisteredItem", params[:proposal_id], params[:enterprise_id])
                
    render :action => 'add_element_currency'
    
  end
  
  
  def add_element_currency
    @element = ExchangePlugin::ExchangeElement.new
    @element.element_id = params[:element_id]
    @element.enterprise_id = params[:enterprise_id]
    @element.element_type = params[:element_type]
    @element.proposal_id = params[:proposal_id]

    @element.save!

  end
  
  def add_element
    @element = ExchangePlugin::ExchangeElement.new
    @element.element_id = params[:element_id]
    @element.enterprise_id = params[:enterprise_id]
    @element.element_type = params[:element_type]
    @element.proposal_id = params[:proposal_id]

    @element.save!
  end

  def remove_element
    @element = ExchangePlugin::ExchangeElement.find params[:id]
    type = @element.element_type
    @element.destroy

  end

  def remove_element_currency
    @element = ExchangePlugin::ExchangeElement.find params[:id]
    @element.destroy
  end

  
  def new_message
    p = ExchangePlugin::Proposal.find params[:proposal_id]

    recipient = (p.enterprise_target_id == @active_organization.id)? p.enterprise_origin : p.enterprise_target

    @message = ExchangePlugin::Message.new_exchange_message(p, @active_organization, recipient, current_user.person, params[:body])
    
    ActionMailer::Base.default_url_options[:host] = request.host_with_port
    ExchangePlugin::Mailer.deliver_new_message_notification @active_organization, recipient, p.exchange.id    


  end

  def close_proposal
    @proposal = ExchangePlugin::Proposal.find params[:proposal_id]
    @proposal.state = "closed"
    @proposal.date_sent = Time.now
    @proposal.save

    @proposal.exchange.state = "negociation"
    @proposal.exchange.save
#    @proposal = ExchangePlugin::Proposal.create
    #como copiar um objeto??
    redirect_to :action => 'exchange_console', :exchange_id => @proposal.exchange_id
  end

  def new_proposal
    exchange = ExchangePlugin::Exchange.find params[:exchange_id]
    proposal_last = exchange.closed_proposals.last

    @proposal = ExchangePlugin::Proposal.new
    @proposal.exchange_id = proposal_last.exchange_id
    @proposal.state = "open"

    @proposal.enterprise_origin = @active_organization
    @proposal.enterprise_target = @proposal.exchange.enterprises.select{|k| k.id != @active_organization.id}.first #not good

    @proposal.save

    proposal_last.exchange_elements.each do |ex|
      ex_el = ExchangePlugin::ExchangeElement.new
      ex_el.element_id = ex.element_id
      ex_el.element_type = ex.element_type
      ex_el.quantity = ex.quantity
      ex_el.proposal_id = @proposal.id
      ex_el.enterprise_id = ex.enterprise_id
      ex_el.save
    end

    ActionMailer::Base.default_url_options[:host] = request.host_with_port
    ExchangePlugin::Mailer.deliver_new_proposal_notification @proposal.enterprise_target, @proposal.enterprise_origin, @proposal.id, @exchange.id    
    
    redirect_to :action => 'exchange_console', :exchange_id => @proposal.exchange_id
  end

  def destroy_proposal
    @proposal = ExchangePlugin::Proposal.find params[:proposal_id]
    exchange_id = @proposal.exchange_id
    @proposal.destroy

    redirect_to :action => 'exchange_console', :exchange_id => exchange_id
  end

  def destroy
    (ExchangePlugin::Exchange.find params[:exchange_id]).destroy
    redirect_to :action => 'index'
  end

  def accept
    @proposal = ExchangePlugin::Proposal.find params[:proposal_id]
    @proposal.exchange.state = "evaluation"
    @proposal.exchange.save
    @proposal.state = "accepted"
    @proposal.save

    redirect_to :action => 'exchange_console', :exchange_id => @proposal.exchange_id
  end


  def evaluate
    @exchange = ExchangePlugin::Exchange.find params[:exchange_id]
    evaluation = EvaluationPlugin::Evaluation.new
    evaluation.object_type = "ExchangePlugin::Exchange"
    evaluation.object_id = params[:exchange_id]
    evaluation.score = params[:score]
    evaluation.text = params[:text]
    evaluation.exchange_result = params[:exchange_result]
    evaluation.evaluator = profile
    evaluation.evaluated_id = params[:theother_id]
    evaluation.save

    if (@exchange.evaluations.count == 2)
        @exchange.state = 'concluded'
        @exchange.concluded_at = Time.now
        @exchange.save
    end

    redirect_to :action => 'exchange_console', :exchange_id => @exchange.id

  end

  def update_quantity
    @element = ExchangePlugin::ExchangeElement.find params[:element_id]
    old_quantity = @element.quantity
    @element.quantity = params[:quantity]
    @element.save
    @exchange = ExchangePlugin::Exchange.find @element.proposal.exchange_id
    
    render :nothing => true
  end

  ## Methods for exchange elements editing###

  private

  def sort_column
    ExchangePlugin::Exchange.column_names.include?(params[:sort]) ? params[:sort] : "updated_at"
  end

  def sort_direction
    %w[asc desc].include?(params[:direction])?params[:direction]:"desc"
  end

  protected
  
  def add_element_helper(element_id, element_type, proposal_id, enterprise_id)
    @element = ExchangePlugin::ExchangeElement.new
    @element.element_id = element_id
    @element.enterprise_id = enterprise_id
    @element.element_type = element_type
    @element.proposal_id = proposal_id

    @element.save!
  end

end
