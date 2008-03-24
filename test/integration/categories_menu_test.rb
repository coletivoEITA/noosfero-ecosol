require "#{File.dirname(__FILE__)}/../test_helper"

class CategoriesMenuTest < ActionController::IntegrationTest

  should 'display link to categories' do
    Category.delete_all
    cat1 = Category.create!(:name => 'Food', :environment => Environment.default, :display_color => 1)
    cat2 = Category.create!(:name => 'Vegetables', :environment => Environment.default, :parent => cat1)

    get '/'

    assert_tag :tag => 'a', :attributes => { :href => '/cat/food/vegetables' }

  end

  should 'display link to sub-categories' do
    Category.delete_all
    cat1 = Category.create!(:name => 'Food', :environment => Environment.default)
    cat2 = Category.create!(:name => 'Vegetables', :environment => Environment.default, :parent => cat1)

    get '/cat/food'

    # there must be a link to the subcategory
    assert_tag :tag => 'a', :attributes => { :href => '/cat/food/vegetables' }

  end

end
