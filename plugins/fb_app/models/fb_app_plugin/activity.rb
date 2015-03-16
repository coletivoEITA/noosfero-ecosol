class FbAppPlugin::Activity < OpenGraphPlugin::Activity

  def self.scrape object_data_url
    params = {id: object_data_url, scrape: true, method: 'post'}
    url = "http://graph.facebook.com?#{params.to_query}"
    Net::HTTP.get URI.parse(url)
  end

  def scrape
    self.class.scrape self.object_data_url
  end

end
