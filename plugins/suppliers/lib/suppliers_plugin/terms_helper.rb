raise 'I18n version 0.6.0 is needed for a good string interpolation' unless I18n::VERSION >= '0.6.0'

module SuppliersPlugin::TermsHelper

  I18nSeparator = '.'
  DefaultContext = 'suppliers_plugin'

  Terms = [:profile, :supplier]
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

  @translations = {}
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

  def default_terms_context
    DefaultContext
  end
  # may be replaced on context (e.g. controller)
  def terms_context
    default_terms_context
  end

  def translate key, options = {}
    translation = I18n.t key, options
    translation % translated_terms
  end

  def translate_with_cache key, options = {}
    cache = (SuppliersPlugin::TermsHelper.cache[I18n.locale] ||= {})
    cache = (cache[terms_context] ||= {})

    hit = cache[key]
    return hit if hit.present?

    cache[key] = translate_without_cache key, options
  end

  private

  def translated_terms keys = Keys, translations = SuppliersPlugin::TermsHelper.translations, transformations = Transformations, sep = I18nSeparator
    translated_terms = (translations[I18n.locale] ||= {})
    translated_terms = (translated_terms[terms_context] ||= {})

    return translated_terms if translated_terms.present?

    keys.each do |key|
      translation = I18n.t! "#{terms_context}.terms.#{key}" rescue nil
      translation = I18n.t! "#{default_terms_context}.terms.#{key}" rescue nil unless translation
      next unless translation.is_a? String

      translated_terms["terms#{sep}#{key}"] = translation
      transformations.each do |transformation|
        translated_terms["terms#{sep}#{key}#{sep}#{transformation}"] = translation.send transformation
      end
    end
    translated_terms
  end

end
