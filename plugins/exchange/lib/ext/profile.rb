require_dependency 'profile'

class Profile

  has_many :profile_exchanges, foreign_key: :profile_id, class_name: "ExchangePlugin::ProfileExchange"
  has_many :exchanges, through: :profile_exchanges

  def has_exchanged e
    found = false
    if (e != self)
      self.exchanges.each do |ex|
        if ex.profiles.first conditions: {id: e.id}
          found = true
          break
        end
      end
    end
    return found
  end

  def exchanges_count
    self.exchanges.count conditions: {state: "concluded"}
  end

  def exchanged_profile_count
    profiles = Array.new
    self.profile_exchanges.each do |e|
      if e.exchange.state == "concluded"
        profiles.push(e.the_other.id)
      end
    end

    return profiles.uniq.count
  end

end
