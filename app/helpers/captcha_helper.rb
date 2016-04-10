module CaptchaHelper

  HiddenField = 'hcaptcha'

  def captcha_verify recaptcha_options = {}
    return true if params[HiddenField].blank?
    return true if verify_recaptcha recaptcha_options
    false
  end

  def hidden_captcha_field
    #"<input type='text' autocomplete='off' autofill='off' name='#{HiddenField}' class='#{HiddenField}'/>"
  end
end
