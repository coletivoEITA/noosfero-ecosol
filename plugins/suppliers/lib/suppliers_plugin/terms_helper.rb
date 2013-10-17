module SuppliersPlugin::TermsHelper

  Terms = [:consumer, :supplier]
  TermsVariations = [:singular, :plural]
  TermsKeys = Terms.map do |term|
    TermsVariations.map{ |var| [term, var].join('.') }
  end.flatten

  protected

  def translated_terms keys = TermsKeys
    raise "Terms' context unset" if @terms_context.blank?
    @translated_terms ||= {}
    return @translated_terms unless @translated_terms.blank?

    keys.each do |key|
      @translated_terms["terms.#{key}"] = I18n.t "#{@terms_context}.terms.#{key}"
    end
    @translated_terms
  end

  def t key, options = {}
    I18n.t(key, options) % translated_terms
  end

end
