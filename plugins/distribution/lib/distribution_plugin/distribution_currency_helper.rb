module DistributionPlugin::DistributionCurrencyHelper

  def self.parse_localized_number number
    return number if number.blank? or number.is_a?(Float)
    number.gsub(I18n.t("number.currency.format.unit"), '').gsub(I18n.t("number.currency.format.delimiter"), '').gsub(I18n.t("number.currency.format.separator"), '.').to_f
  end

  def self.parse_currency currency
    self.parse_localized_number currency
  end

  module ClassMethods

    def has_number_with_locale field
      define_method "#{field}=" do |value|
        self[field] = DistributionPlugin::DistributionCurrencyHelper.parse_localized_number value
      end

      define_method "#{field}_as_currency_number" do |*args, &block|
        number = send(field, *args, &block) rescue self[field]
        string = ActionController::Base.helpers.number_to_currency(number, :unit => '')
        string.gsub!(' ', '') if string
        string
      end
      define_method "#{field}_as_currency" do |*args, &block|
        number = send(field, *args, &block) rescue self[field]
        ActionController::Base.helpers.number_to_currency(number)
      end
    end

    def has_currency field
      self.has_number_with_locale field
    end

  end

  module InstanceMethods

  end

end
