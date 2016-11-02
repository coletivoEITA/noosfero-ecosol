module SuppliersPlugin
  class Settings < Noosfero::Plugin::Settings

    def initialize object
      super object, SuppliersPlugin
    end

    def margin_percentage
      super || 0
    end

  end
end
