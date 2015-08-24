require "#{File.dirname(__FILE__)}/../test_helper"

class TextileArticleTest < ActiveSupport::TestCase

  should 'define type facet' do
    a = TextileArticle.new
    assert_equal [[a.send(:solr_f_type), TextArticle.type_name, 1]],
      TextileArticle.send(:solr_f_type_proc, TextileArticle.facet_by_id(:solr_f_type), [[a.send(:solr_f_type), 1]])
  end

end
