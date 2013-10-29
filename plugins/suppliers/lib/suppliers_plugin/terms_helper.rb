module SuppliersPlugin::TermsHelper

  # '.' ins't supported by the % format function (altought it works on some newer systems)
  # FIXME remove when a newer ruby/system is required as it affects performance
  Separator = '_'
  I18nSeparator = '.'

  Terms = [:consumer, :supplier]
  Auxiliars = [
    nil,
    #
    :it, :one,
    :to_it,
    #
    :article, :undefined_article, :at, :in, :on, :to, :from, :by, :which, :this, :your,
    :to_article, :at_article, :from_article, :by_article,
    :from_this, :from_which, :from_which_article, :by_your,
    # adjectives
    :none, :own, :new,
    :by_own, :new_undefined_article
  ]
  Variations = [nil, :singular, :plural]
  Transformations = [:capitalize]

  # FORMAT: terms.term.auxiliar.variation.transformation
  Keys = Terms.map do |term|
    Auxiliars.map do |auxiliar|
      Variations.map do |variation|
        [term, auxiliar, variation].compact.join I18nSeparator
      end
    end
  end.flatten

  @translations = HashWithIndifferentAccess.new
  def self.translations
    @translations
  end

  @cache = {}
  def self.cache
    @cache
  end

  protected

  def self.included base
    base.alias_method_chain :translate, :cache
    base.send :alias_method, :t, :translate
  end

  # may be replaced on context (e.g. controller)
  def terms_context
    'suppliers_plugin'
  end

  def translate key, options = {}
    translation = I18n.t key, options
    sub_separator_items translation
    translation % translated_terms
  end

  def translate_with_cache key, options = {}
    cache = (SuppliersPlugin::TermsHelper.cache[I18n.locale] ||= {})
    hit = cache[key]
    return hit if hit.present?

    cache[key] = translate_without_cache key, options
  end

  private

  def sub_separator str
    str.gsub I18nSeparator, Separator
  end
  def sub_separator_items str
    str.gsub!(/\%\{[^\}]*\}/){ |x| sub_separator x }
    str
  end

  def translated_terms keys = Keys, translations = SuppliersPlugin::TermsHelper.translations, transformations = Transformations, sep = Separator
    translated_terms ||= (translations[I18n.locale] ||= HashWithIndifferentAccess.new)
    return translated_terms if translated_terms.present?

    keys.each do |key|
      translation = I18n.t! "#{terms_context}.terms.#{key}" rescue nil
      next unless translation.is_a? String

      processed_key = sub_separator key

      translated_terms["terms#{sep}#{processed_key}"] = translation
      transformations.map do |transformation|
        translated_terms["terms#{sep}#{processed_key}#{sep}#{transformation}"] = translation.send transformation
      end
    end
    translated_terms
  end

end
