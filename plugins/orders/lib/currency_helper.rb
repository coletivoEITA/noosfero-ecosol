module CurrencyHelper

  def self.parse_localized_number number
    return number if number.blank?
    number = number.to_s
    number.gsub(I18n.t("number.currency.format.unit"), '').gsub(I18n.t("number.currency.format.delimiter"), '').gsub(I18n.t("number.currency.format.separator"), '.').to_f
  end

  def self.parse_currency currency
    self.parse_localized_number currency
  end

  def self.number_as_currency_number number
    string = ActionController::Base.helpers.number_to_currency(number, :unit => '')
    string.gsub!(' ', '') if string
    string
  end

  def self.number_as_currency number
    ActionController::Base.helpers.number_to_currency(number)
  end

  module ClassMethods

    def has_number_with_locale attr
      define_method "#{attr}_with_locale=" do |value|
        value = CurrencyHelper.parse_localized_number value if value.is_a? String
        self.send "#{attr}_without_locale=", value
      end
      alias_method_chain "#{attr}=", :locale rescue nil # rescue if method don't have a setter

      define_method "#{attr}_as_currency" do |*args, &block|
        number = send attr, *args, &block
        CurrencyHelper.number_as_currency number
      end
      define_method "#{attr}_as_currency_number" do |*args, &block|
        number = send attr, *args, &block
        CurrencyHelper.number_as_currency_number number
      end
    end

    def has_currency attr
      self.has_number_with_locale attr
    end

  end

  module InstanceMethods

  end

end
