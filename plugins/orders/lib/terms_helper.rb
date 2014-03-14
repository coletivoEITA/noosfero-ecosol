raise 'I18n version 0.6.0 is needed for a good string interpolation' unless I18n::VERSION >= '0.6.0'

module TermsHelper

  I18nSeparator = '.'

  Terms = [:profile, :supplier]
  Auxiliars = [
    nil,
    #
    :it, :one,
    :to_it,
    #
    :article, :undefined_article,
    :in, :which, :this, :your,
    :at, :at_article,
    :to, :to_article,
    :on, :on_your,
    :by, :by_article,
    :from, :from_article, :from_this, :from_which, :from_which_article, :by_your,
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
    base.send :include, I18nAutoScope
    base.alias_method_chain :translate, :terms
    base.alias_method_chain :translate, :terms_cache
    base.send :alias_method, :t, :translate
  end

  def translate_with_terms key, options = {}
    translation = translate_without_terms key, options
    translation % translated_terms
  end

  def translate_with_terms_cache key, options = {}
    cache = (TermsHelper.cache[I18n.locale] ||= {})
    cache = (cache[i18n_scope] ||= {})

    hit = cache[key]
    return hit if hit.present?

    cache[key] = translate_without_terms_cache key, options
  end

  private

  def translated_terms keys = Keys, translations = TermsHelper.translations, transformations = Transformations, sep = I18nSeparator
    translated_terms = (translations[I18n.locale] ||= {})
    translated_terms = (translated_terms[i18n_scope] ||= {})

    return translated_terms if translated_terms.present?

    keys.each do |key|
      translation = self.translate_with_auto_scope "terms#{sep}#{key}", :raise => true rescue nil
      next unless translation.is_a? String

      translated_terms["terms#{sep}#{key}"] = translation
      transformations.each do |transformation|
        translated_terms["terms#{sep}#{key}#{sep}#{transformation}"] = translation.send transformation
      end
    end
    translated_terms
  end

end
