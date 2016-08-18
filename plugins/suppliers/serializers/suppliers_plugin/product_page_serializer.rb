module SuppliersPlugin
  class ProductPageSerializer < ApplicationSerializer

    has_many :products
    has_many :units
    has_many :categories
    has_many :suppliers

    def products
      object[:products]
    end
    def units
      object[:units]
    end
    def categories
      object[:categories].map{ |pc| [pc.name, pc.id]}.insert(0,[scope.t('suppliers_plugin.views.product.all_the_categories'), ""])
    end
    def suppliers
      object[:profile].suppliers.map do |s|
        [s.abbreviation_or_name, s.id]
      end.sort{ |a,b| a[0].downcase <=> b[0].downcase }
    end
  end
end
