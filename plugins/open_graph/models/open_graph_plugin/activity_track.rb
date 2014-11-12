class OpenGraphPlugin::ActivityTrack < OpenGraphPlugin::Track

  def self.objects
    [
      :blog_post,
      :friendship,
      :gallery_image,
      :uploaded_file,
    ]
  end

  validates_inclusion_of :object, in: self.objects

end

