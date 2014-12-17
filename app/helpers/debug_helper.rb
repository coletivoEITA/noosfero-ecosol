
module DebugHelper

  def headers_table
    content_tag 'table', border: '1' do
      request.env.select {|k,v| k.match("^HTTP.*")}.map do
        content_tag 'tr' do
          content_tag('td', header[0].split('_',2)[1]) +
          content_tag('td', header[1])
        end
      end
    end
  end

end
