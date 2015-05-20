module AdvertisementsHelper

  def concat_page_number(text)
    [text, "#{params[:page].to_i > 1 ? "страница № #{params[:page]}" : ''}"].delete_if{|e| e.to_s == ''}.join(' ')
  end

  def bb_tags(string, tags)
    tags.each_pair do |name, value|
      string.to_s.gsub!("[b]#{name.to_s}[/b]", value.to_s)
    end
    return string
  end

  def advertisements_pagination
    url_params = params.dup
    url_params[:advertisement].delete_if{|e| url_params[:advertisement][e].blank?}
    url_params.delete :utf8
    url_params.delete :advertisement if url_params[:advertisement].empty?
    url_params.delete :url if url_params[:url].present?
    max_pages = 1000000 / @limit
    render 'shared/pagination', :pages => (max_pages < @pages ? max_pages : @pages), :current_page => (url_params[:page] || 1).to_i, :url_path => method(params[:url].present? ? :url_for : :root_path), :url_params => url_params
  end

  def generate_ac_source src
    src.map{ |s| { "#{s[:title]}" => s[:id] }}.to_json
  end

  def render_button(location)
    render 'advertisements/inputs/check_button', location: location
  end


  def render_search_input(search_attribute)
    if search_attribute == 'room_from'
        attr = {
            name: :room,
            value: params[:advertisement].try(:[], :room) || {},
        }
        return render '/advertisements/search_inputs/interval', attr: attr.merge({class_name: nil})
    elsif match = search_attribute.match(/(.+)(_from)$/i)

      suffix = match[1]
      puts suffix

      attr = {
          name_from: "#{suffix}_from".to_sym,
          name_to: "#{suffix}_to".to_sym,
          value_from: params[:advertisement].try(:[], "#{suffix}_from".to_sym),
          value_to: params[:advertisement].try(:[], "#{suffix}_to".to_sym),
      }
      if suffix == 'price'
        return render '/advertisements/search_inputs/price', attr: attr.merge({class_name: 'fa-rouble'})
      end
      if suffix == 'floor' || suffix == 'floor_cnt'
        return render '/advertisements/search_inputs/integer', attr: attr.merge({class_name: nil}).merge({class_name_input: 'w-2'})
      end
      if suffix == 'space' || suffix == 'outdoors_space'
        return render '/advertisements/search_inputs/numeric', attr: attr.merge({class_name: nil}).merge({class_name_input: 'w-3'})
      end

    else

      attr = {
          name: search_attribute.to_sym,
          value: params[:advertisement].try(:[], search_attribute.to_sym),
      }

      if search_attribute == 'mortgage'
        return render '/advertisements/search_inputs/boolean', attr: attr.merge({class_name: 'fa-bank'}).merge({btn_class_name: 'btn-default'}).merge({ owner: false })
      end

      if search_attribute == 'owner'
        return render '/advertisements/search_inputs/boolean', attr: attr.merge({class_name: 'fa-check'}).merge({btn_class_name: 'btn-default'}).merge({ owner: true })
      end

    end

    raise "type not found #{search_attribute}"
  end

  def render_input(name_from, name_to, value_from, value_to)
    attr = {
        name_from: name_from,
        name_to: name_to,
        value_from: value_from,
        value_to: value_to
    }

    if name_from == :price_from
      return render '/advertisements/inputs/price', attr
    end

    if (name_from == :floor_from) ||
       (name_from == :floor_cnt_from)||
       (name_from == :room_from)
      return render '/advertisements/inputs/integer', attr
    end

    if (name_from == :space_from) || (name_from == :outdoors_space_from)
      return render '/advertisements/inputs/numeric', attr
    end

    if (name_from == :comment)
      return render '/advertisements/inputs/textarea', attr.merge(icon: 'fa-bullhorn')
    end

    if (name_from == :not_for_agents) || (name_from == :mortgage)
      return render '/advertisements/inputs/boolean', attr
    end

    if (name_from == :landmark)
      return render '/advertisements/inputs/text', attr.merge(icon: 'fa-tag')
    end

  end

  def render_icon icon
    icons = {
        agent: '<i class="fa fa-cube"></i>'.html_safe,
        owner: '<i class="fa fa-check"></i>'.html_safe
    }
    icons[icon]
  end

  def render_model_errors resource
    if resource.errors.present?
      info =  '<p><div class="alert alert-danger">'
      info += resource.errors.full_messages.join(';')
      info += '</div></p>'
      info.gsub!('Email не найдена','Пользователь с такими данными не найден.')
      return info.html_safe
    end
  end

  def should_not_be_orange?
    current_page?(controller: '/advertisements', action: :new) || current_page?(controller: '/advertisements', action: :create) ||
    current_page?(controller: '/devise/sessions', action: :new)  || current_page?(controller: '/passwords', action: :new) ||
    current_page?(controller: '/passwords', action: :edit)|| current_page?(controller: '/registrations', action: :new) ||
    current_page?(controller: '/registrations', action: :edit) || current_page?(controller: '/cabinet')
  end

end

