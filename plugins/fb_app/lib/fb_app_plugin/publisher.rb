class FbAppPlugin::Publisher < OpenGraphPlugin::Publisher

  def publish_story object_data, actor, story
    OpenGraphPlugin.context = FbAppPlugin::Activity.context
    a = FbAppPlugin::Activity.new object_data: object_data, actor: actor, story: story
    a.dispatch_publications
    a.save
  end

end
