class ExchangePluginMyprofileController < MyProfileController

  no_design_blocks
  protect 'edit_profile', :profile
  before_filter :set_mailer_host

  helper ExchangePlugin::ExchangeDisplayHelper

  def index
    @exchanges_enterprise = ExchangePlugin::ExchangeEnterprise.all.select{|ex| ex.enterprise_id == profile.id}

    @active_exchanges_enterprise = @exchanges_enterprise.select{|ex| (ex.exchange.state == "negociation")}

    @inactive_exchanges_enterprise = @exchanges_enterprise.select{|ex| ((ex.exchange.state == "concluded") || (ex.exchange.state == "cancelled"))}
  end

  def exchange_console
    @exchange = ExchangePlugin::Exchange.find params[:exchange_id]

    @proposals = @exchange.proposals.all(:order => "created_at DESC")
    @current_proposal = @proposals.first

    @target = @current_proposal.enterprise_target
    @origin = @current_proposal.enterprise_origin
    @theother = @exchange.enterprises.find(:first, :conditions => ["enterprise_id != ?",profile.id])

    @theother_knowledges = CmsLearningPlugin::Learning.all.select{|k| k.profile.id == @theother.id} - @current_proposal.knowledges
    @profile_knowledges = CmsLearningPlugin::Learning.all.select{|k| k.profile.id == @profile.id} - @current_proposal.knowledges
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
    proposal = ExchangePlugin::Proposal.find params[:proposal_id]
    sender, recipient = (proposal.enterprise_target_id == @active_organization.id) ?
      [proposal.enterprise_target, proposal.enterprise_origin] :
      [proposal.enterprise_origin, proposal.enterprise_target]

    @message = ExchangePlugin::Message.new_exchange_message proposal, sender, recipient, user, params[:body]

    ExchangePlugin::Mailer.deliver_new_message_notification @active_organization, recipient, proposal.exchange_id
  end

  def close_proposal
    @proposal = ExchangePlugin::Proposal.find params[:proposal_id]
    @proposal.state = "closed"
    @proposal.date_sent = Time.now
    @proposal.save!

    @proposal.exchange.state = "negociation"
    @proposal.exchange.save!

    ExchangePlugin::Mailer.deliver_new_proposal_notification @proposal.enterprise_target, @proposal.enterprise_origin, @proposal.id, @proposal.exchange.id

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

    @proposal.save!

    proposal_last.exchange_elements.each do |ex|
      ex_el = ExchangePlugin::ExchangeElement.new
      ex_el.element_id = ex.element_id
      ex_el.element_type = ex.element_type
      ex_el.quantity = ex.quantity
      ex_el.proposal_id = @proposal.id
      ex_el.enterprise_id = ex.enterprise_id
      ex_el.save!
    end

    redirect_to :action => 'exchange_console', :exchange_id => @proposal.exchange_id
  end

  def destroy_proposal
    @proposal = ExchangePlugin::Proposal.find params[:proposal_id]
    exchange_id = @proposal.exchange_id
    @proposal.destroy

    redirect_to :action => 'exchange_console', :exchange_id => exchange_id
  end

  def destroy
    @exchange = ExchangePlugin::Exchange.find params[:exchange_id]
    @exchange.destroy
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
    evaluation.result = params[:result]
    evaluation.evaluator = profile
    evaluation.evaluated_id = params[:theother_id]
    evaluation.save

    if @exchange.evaluations.count == 2
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

  protected

  def add_element_helper(element_id, element_type, proposal_id, enterprise_id)
    @element = ExchangePlugin::ExchangeElement.new
    @element.element_id = element_id
    @element.enterprise_id = enterprise_id
    @element.element_type = element_type
    @element.proposal_id = proposal_id

    @element.save!
  end

  def set_mailer_host
    ExchangePlugin::Mailer.default_url_options = {:host => request.host_with_port}
  end

end
