
class MetadataPlugin::Spec

  Controllers = {
    manage_products: {
      variable: :@product,
    },
    content_viewer: {
      variable: :@page,
    },
    # fallback
    profile: {
      variable: :@profile,
    },
    # last fallback
    environment: {
      variable: :@environment,
    },
  }

end
