require_dependency 'enterprise'

class Enterprise

  has_many :exchanges_enterprises, :foreign_key => "enterprise_id", :class_name => "ExchangePlugin::ExchangeEnterprise"

  has_many :exchanges, :through => :exchanges_enterprises
  
  def has_exchanged (e)
    found = false
    if (e != self) 
      self.exchanges.each do |ex| 
        if ex.enterprises.find(:first,:conditions => {:id => e.id} )
          found = true
          break
        end
      end
    end
    return found
  end
  
end
