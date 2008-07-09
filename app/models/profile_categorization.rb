class ProfileCategorization < ActiveRecord::Base
  set_table_name :categories_profiles
  belongs_to :profile
  belongs_to :category

  def self.add_category_to_profile(category, profile)
    return if self.find_by_category_id_and_profile_id(category.id, profile.id)
    connection.execute("insert into categories_profiles (category_id, profile_id) values(#{category.id}, #{profile.id})")

    c = category.parent
    while !c.nil? && !self.find(:first, :conditions => {:profile_id => profile, :category_id => c}) 
      connection.execute("insert into categories_profiles (category_id, profile_id, virtual) values(#{c.id}, #{profile.id}, 1>0)")
      c = c.parent
    end
  end

  def self.remove_all_for(profile)
    self.delete_all(:profile_id => profile.id)
  end

  def self.remove_region(profile)
    region = profile.categories.find(:first, :conditions => "type = 'Region'")
    if region
      ids = region.hierarchy.map(&:id)
      self.delete_all(:profile_id => profile.id, :category_id => ids)
    end
  end

end
