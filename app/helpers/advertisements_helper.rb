module AdvertisementsHelper

  def get_neighbors location
    Location.find_by_id(location.to_i).neighbors
  end

  #cond[ :tag, :class, :text]
  def render_html_tag cond
    "<#{ cond[:tag] } class=\"#{ cond[:class] }\">#{ cond[:text] }<\/#{cond[:tag]}>".html_safe
  end

  def render_input(name_from, type_from, name_to, type_to, value_from = nil, value_to = nil)

    if (type_from == :floor_from) ||
       (type_from == :floor_cnt_from)||
       (type_from == :room_from)||
       (type_from == :price_from)
      return render '/advertisements/inputs/integer', name_from: name_from, name_to: name_to, value_from: value_from, value_to: value_to
    end

    if (type_from == :space_from) || (type_from == :outdoors_space_from)
      return render '/advertisements/inputs/numeric', name_from: name_from, name_to: name_to, value_from: value_from, value_to: value_to
    end

    if (type_from == :comment) || (type_from == :private_comment)
      return render '/advertisements/inputs/textarea', name_from: name_from, name_to: name_to, value_from: value_from, value_to: value_to
    end


    if (type_from == :not_for_agents) || (type_from == :mortgage)
      return render '/advertisements/inputs/boolean', name_from: name_from, name_to: name_to, value_from: value_from, value_to: value_to
    end

    if (type_from == :landmark)
      return render '/advertisements/inputs/text', name_from: name_from, name_to: name_to, value_from: value_from, value_to: value_to
    end


    raise %{
      if type_from == :#{type_from}
        return render '/advertisements/inputs/#{type_from}_#{type_to}', name_from: name_from, name_to: name_to, value_from: value_from, value_to: value_to
      end
    }

  end
end

