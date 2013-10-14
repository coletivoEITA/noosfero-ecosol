module SuppliersPlugin::TermsHelper

  Terms = [:consumer, :supplier]
  TermsVariations = [:singular, :plural]
  TermsTransformations = [:capitalize]
  TermsKeys = Terms.map do |term|
    TermsVariations.map{ |variation| [term, variation].join('.') }
  end.flatten

  protected

  def translated_terms keys = TermsKeys
    @translated_terms ||= {}
    return @translated_terms unless @translated_terms.blank?

    @terms_context ||= 'suppliers_plugin'
    keys.each do |key|
      translation = I18n.t "#{@terms_context}.terms.#{key}"
      @translated_terms["terms.#{key}"] = translation

      TermsTransformations.map do |transformation|
        @translated_terms["terms.#{key}.#{transformation}"] = translation.send transformation
      end
    end
    @translated_terms
  end

  def t key, options = {}
    I18n.t(key, options) % translated_terms
  end

end
