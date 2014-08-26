module AdvertisementsHelper
  def succeed omg = ''
    #БЫСТРЫЙ БАГОФИКС
    true
  end

  def get_neighbors location
    Location.find_by_id(location.to_i).neighbors
  end

  #cond[ :tag, :class, :text]
  def render_html_tag cond
    "<#{ cond[:tag] } class=\"#{ cond[:class] }\">#{ cond[:text] }<\/#{cond[:tag]}>".html_safe
  end
end

