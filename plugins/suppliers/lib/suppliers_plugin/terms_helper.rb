module SuppliersPlugin::TermsHelper

  Terms = [:consumer, :supplier]
  # '.' ins't supported by the % format function (altought it works on some newer systems)
  TermsSeparator = '_'
  TermsVariations = [:singular, :plural]
  TermsTransformations = [:capitalize]
  TermsKeys = Terms.map do |term|
    TermsVariations.map{ |variation| [term, variation].join('.') }
  end.flatten

  protected

  def sub_separator str
    str.gsub '.', TermsSeparator
  end

  def sub_separator_items str
    str.gsub!(/\%\{[^\}]*\}/){ |x| sub_separator x }
    str
  end

  def translated_terms keys = TermsKeys, transformations = TermsTransformations, sep = TermsSeparator
    @translated_terms ||= HashWithIndifferentAccess.new
    return @translated_terms unless @translated_terms.blank?

    @terms_context ||= 'suppliers_plugin'
    keys.each do |key|
      translation = I18n.t "#{@terms_context}.terms.#{key}"
      new_key = sub_separator key
      @translated_terms["terms#{sep}#{new_key}"] = translation

      transformations.map do |transformation|
        @translated_terms["terms#{sep}#{new_key}#{sep}#{transformation}"] = translation.send transformation
      end
    end
    @translated_terms
  end

  def t key, options = {}
    translation = I18n.t key, options
    sub_separator_items translation
    translation % translated_terms
  end

end
