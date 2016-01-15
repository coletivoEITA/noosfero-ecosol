class CmsLearningPluginMyprofileController < MyProfileController

  protect 'edit_profile', :profile

  def product_categories
    @categories = ProductCategory.all :limit => 20, :conditions => ["name ~* ?", params[:q]]
    respond_to do |format|
      format.html
      format.json { render :json => @categories.collect{ |i| {:id => i.id, :name => i.name } } }
    end
  end

  def persons
    @persons = Person.all :limit => 20, :conditions => ["name ~* ?", params[:q]]
    respond_to do |format|
      format.html
      format.json { render :json => @persons.collect{ |i| {:id => i.id, :name => i.name } } }
    end
  end
end

