module AdvertisementsHelper

  def get_neighbors location
    Location.find_by_id(location.to_i).neighbors
  end

  def generate_ac_source src
    src.map{ |s| { "#{s[:title]}" => s[:id] }}.to_json
  end

  def render_button(location)
    render 'advertisements/inputs/check_button', location: location
  end

  #cond[ :tag, :class, :text]
  def render_html_tag cond
    "<#{ cond[:tag] } class=\"#{ cond[:class] }\">#{ cond[:text] }<\/#{cond[:tag]}>".html_safe
  end

  def render_input(name_from, name_to, value_from, value_to)
    attr = {
        name_from: name_from,
        name_to: name_to,
        value_from: value_from,
        value_to: value_to
    }

    if (name_from == :floor_from) ||
       (name_from == :floor_cnt_from)||
       (name_from == :room_from)||
       (name_from == :price_from)
      return render '/advertisements/inputs/integer', attr
    end

    if (name_from == :space_from) || (name_from == :outdoors_space_from)
      return render '/advertisements/inputs/numeric', attr
    end

    if (name_from == :comment) || (name_from == :private_comment)
      return render '/advertisements/inputs/textarea', attr
    end


    if (name_from == :not_for_agents) || (name_from == :mortgage)
      return render '/advertisements/inputs/boolean', attr
    end

    if (name_from == :landmark)
      return render '/advertisements/inputs/text', attr
    end

  end
end

