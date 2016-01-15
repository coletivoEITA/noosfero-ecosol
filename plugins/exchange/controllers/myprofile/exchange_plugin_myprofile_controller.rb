class ExchangePluginMyprofileController < MyProfileController

  no_design_blocks
  protect 'edit_profile', :profile
  before_filter :set_mailer_host

  helper ExchangePlugin::ExchangeDisplayHelper

  def index
    @profile_exchanges = ExchangePlugin::ProfileExchange.where(profile_id: profile.id)
    @active_exchanges = @profile_exchanges.select{|ex| (ex.exchange.state == "negociation")}
    @inactive_exchanges = @profile_exchanges.select{|ex| ((ex.exchange.state == "concluded") || (ex.exchange.state == "cancelled"))}
  end

  def exchange_console
    @exchange = ExchangePlugin::Exchange.find params[:exchange_id]

    @proposals = @exchange.proposals.order("created_at DESC")
    @current_proposal = @proposals.first

    @target = @current_proposal.target
    @origin = @current_proposal.origin
    @theother = @exchange.profiles.first conditions: ["profile_id <> ?", profile.id]

    @theother_knowledges = CmsLearningPlugin::Learning.all.select{|k| k.profile.id == @theother.id} - @current_proposal.knowledges
    @profile_knowledges = CmsLearningPlugin::Learning.all.select{|k| k.profile.id == @profile.id} - @current_proposal.knowledges
  end

  def new_message
    proposal = ExchangePlugin::Proposal.find params[:proposal_id]
    sender, recipient = (proposal.target_id == @active_organization.id) ?
      [proposal.target, proposal.origin] :
      [proposal.origin, proposal.target]

    @message = ExchangePlugin::Message.new_exchange_message proposal, sender, recipient, user, params[:body]

    ExchangePlugin::Mailer.new_message_notification(@active_organization, recipient, proposal.exchange_id).deliver
  end

  def close_proposal
    @proposal = ExchangePlugin::Proposal.find params[:proposal_id]
    @proposal.state = "closed"
    @proposal.sent_at = Time.now
    @proposal.save!

    @proposal.exchange.state = "negociation"
    @proposal.exchange.save!

    ExchangePlugin::Mailer.new_proposal_notification(@proposal.target, @proposal.origin, @proposal.id, @proposal.exchange.id).deliver

    redirect_to action: 'exchange_console', exchange_id: @proposal.exchange_id
  end

  def new_proposal
    exchange = ExchangePlugin::Exchange.find params[:exchange_id]
    proposal_last = exchange.closed_proposals.last

    @proposal = ExchangePlugin::Proposal.new
    @proposal.exchange_id = proposal_last.exchange_id
    @proposal.state = "open"

    @proposal.origin = @active_organization
    @proposal.target = @proposal.exchange.profiles.select{|k| k.id != @active_organization.id}.first #not good

    @proposal.save!

    proposal_last.elements.each do |ex|
      ex_el = ExchangePlugin::Element.new
      ex_el.object_id = ex.object_id
      ex_el.object_type = ex.object_type
      ex_el.quantity = ex.quantity
      ex_el.proposal_id = @proposal.id
      ex_el.profile_id = ex.profile_id
      ex_el.save!
    end

    redirect_to action: 'exchange_console', exchange_id: @proposal.exchange_id
  end

  def destroy_proposal
    @proposal = ExchangePlugin::Proposal.find params[:proposal_id]
    exchange_id = @proposal.exchange_id
    @proposal.destroy

    redirect_to action: 'exchange_console', exchange_id: exchange_id
  end

  def destroy
    @exchange = ExchangePlugin::Exchange.find params[:exchange_id]
    @exchange.destroy
    redirect_to action: 'index'
  end

  def accept
    @proposal = ExchangePlugin::Proposal.find params[:proposal_id]
    @proposal.exchange.state = "evaluation"
    @proposal.exchange.save
    @proposal.state = "accepted"
    @proposal.save

    redirect_to action: 'exchange_console', exchange_id: @proposal.exchange_id
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

    redirect_to action: 'exchange_console', exchange_id: @exchange.id
  end

  protected

  def set_mailer_host
    ExchangePlugin::Mailer.default_url_options = {host: request.host_with_port}
  end

end
