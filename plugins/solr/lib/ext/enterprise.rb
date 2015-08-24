require_dependency 'enterprise'
require_dependency "#{File.dirname __FILE__}/profile"

ActiveSupport.run_load_hooks :solr_enterprise

class Enterprise

  after_save_reindex [:products], with: :delayed_job
  solr_extra_data_for_index :solr_product_categories_names

  def solr_product_categories_names
    self.product_categories.map(&:name).uniq
  end

end
