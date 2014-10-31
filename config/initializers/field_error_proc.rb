ActionView::Base.field_error_proc = Proc.new do |html_tag, instance|
  html = html_tag
  elements = Nokogiri::HTML::DocumentFragment.parse(html_tag).css 'input, textarea, select'
  elements.each do
    if instance.error_message.kind_of?(Array)
      html = %(#{html_tag}<span class="help-inline">&nbsp;#{instance.error_message.join(',')}</span>).html_safe
    else
      html = %(#{html_tag}<span class="help-inline">&nbsp;#{instance.error_message}</span>).html_safe
    end
  end
  html
end