class ConsumersCoopPlugin::HeaderImage < ActiveRecord::Base

  self.table_name = :images

  attr_accessible :uploaded_data

  has_attachment :content_type => :image,
                 :storage => :file_system,
                 :path_prefix => 'public/image_uploads',
                 :resize_to => 'crop: 1040x90',
                 :max_size => 2.megabytes # remember to update validate message below

  validates_attachment :size => I18n.t('consumers_coop_plugin.models.header_image.fn_of_uploaded_file_w')

  protected

  # Override image resizing method for adding crop support
  def resize_image img, size
    # resize_image take size in a number of formats, we just want
    # Strings in the form of "crop: WxH"
    if (size.is_a?(String) && size =~ /^crop: (\d*)x(\d*)/i) || (size.is_a?(Array) && size.first.is_a?(String) && size.first =~ /^crop: (\d*)x(\d*)/i)
      img.crop_resized!($1.to_i, $2.to_i, Magick::CenterGravity)
      # We need to save the resized image in the same way the
      # orignal does.
      temp_paths << write_to_temp_file(img.to_blob)
    else
      super # Otherwise let attachment_fu handle it
    end
  end

end
