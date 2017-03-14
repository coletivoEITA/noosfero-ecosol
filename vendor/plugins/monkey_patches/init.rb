ActionDispatch::Reloader.to_prepare do
  # WORKAROUND: AttachmentFu depends on Rails.root
  require 'technoweenie/attachment_fu'
  require_relative 'attachment_fu_validates_attachment/init'
  require_relative 'attachment_fu/init'
end
