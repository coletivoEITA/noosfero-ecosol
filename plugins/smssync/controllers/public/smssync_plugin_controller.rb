class SmssyncPluginController < PublicController

  def index
    request.session_options[:skip] = true
    if request.post?
	    if params[:task] == 'result'
        get_sms_delivery_report
      elsif params[:task] == 'sent'
    		get_sent_message_uuids
      else
    		get_message
      end
    else
    	send_task
    	send_messages_uuids_for_sms_delivery_report
    end
  end

  protected

  def get_message
    @from = params[:from]
    @message = params[:message]
    @uuid = params[:message_id]
    @sent_to = params[:sent_to]
    @sent_timestamp = params[:sent_timestamp]
    @device_id = params[:device_id]

    if SmssyncPlugin.secret.present? and SmssyncPlugin.secret != params[:secret]
      return send_error "The secret value sent from the device does not match the one on the server"
    end

    return send_error 'The from variable was not set' if @from.blank?
    return send_error 'The message variable was not set' if @message.blank?
    return send_error unless @uuid.present? and @sent_timestamp.present?

    @message = SmssyncPlugin::Message.create! from: @from, message: @message, uuid: @uuid, sent_to: @sent_to, sent_timestamp: @sent_timestamp, device_id: @device_id
    return render json: {
      payload: {success: true, error: nil}
    }
  end


  def get_sms_delivery_report
  end

  def get_sent_message_uuids
  end

  def send_task
  end

  def send_messages_uuids_for_sms_delivery_report
  end

  def send_error error=nil
    render json: {
      payload: {success: false, error: error}
    }
  end

end
