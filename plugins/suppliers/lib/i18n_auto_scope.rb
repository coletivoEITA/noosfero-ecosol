
module I18nAutoScope

  DefaultScope = 'suppliers_plugin'

  # should be replaced on controller (e.g. controller)
  def i18n_scope
    DefaultScope
  end

  protected

  def self.included base
    base.send :define_method, :translate, I18n.method(:translate).to_proc unless base.respond_to? :translate

    base.alias_method_chain :translate, :auto_scope
    base.send :alias_method, :t, :translate
  end

  def translate_with_auto_scope key, options = {}
    options[:raise] = true
    translation = self.translate_without_auto_scope key, options rescue nil

    unless translation
      i18n_scope.to_a.each do |scope|
        options[:scope] = scope
        return translation if (translation = self.translate_without_auto_scope key, options rescue nil)
      end
    end
    unless translation
      # sup comes from SuperProxy
      translation = self.translate_without_auto_scope key, options rescue nil if (options[:scope] = sup.i18n_scope rescue nil)
    end

    translation
  end

end
