require 'nokogiri'

module WhiteListFilter

  def check_iframe_on_content(content, trusted_sites)
    if content.blank? || !content.include?('iframe')
      return content
    end
    content.gsub!(/<iframe[^>]*>\s*<\/iframe>/i) do |iframe|
      result = ''
      unless iframe =~ /src=['"].*src=['"]/
        trusted_sites.each do |trusted_site|
          re_dom = trusted_site.gsub('.', '\.')
          if iframe =~ /src=["'](https?:)?\/\/(www\.)?#{re_dom}\//
            result = iframe
          end
        end
      end
      result
    end
  end

  module ClassMethods
    def filter_iframes(*opts)
      options = opts.last.is_a?(Hash) && opts.pop || {}
      white_list_method = options[:whitelist] || :iframe_whitelist
      opts.each do |field|
        before_validation do |obj|
          content = obj.send field
          content = obj.check_iframe_on_content content, obj.instance_eval(&white_list_method)
          obj.send "#{field}=".freeze, content
        end
      end
    end
  end

  def self.included(c)
    c.send(:extend, WhiteListFilter::ClassMethods)
  end
end
