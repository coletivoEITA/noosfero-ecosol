class DistributionPluginHeaderImage < ActiveRecord::Base
  set_table_name 'images'

  has_attachment :content_type => :image, 
                 :storage => :file_system, 
                 :path_prefix => 'public/image_uploads',
                 :resize_to => '960x110>',
                 :max_size => 500.kilobytes # remember to update validate message below

  validates_attachment :size => N_("%{fn} of uploaded file was larger than the maximum size of 500.0 KB")

end
