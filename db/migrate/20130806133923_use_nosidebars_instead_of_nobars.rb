class UseNosidebarsInsteadOfNobars < ActiveRecord::Migration
  def self.up
    Profile.all.each do |profile|
      profile.layout_template = 'nosidebars' if profile.layout_template == 'nobars'
      profile.save false
    end
    if e = Environment.default
      e.layout_template = 'nosidebars'
      e.save!
    end
  end

  def self.down
  end
end
