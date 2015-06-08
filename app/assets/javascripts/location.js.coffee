
@getChildren = (event, callback)->
  $this = $(this)
  params = {'parent_id': $this.attr('lid'), 'editable': true}
  if $('.click_additional_search_params_action').length > 0
    offer_types = $.grep($('[name="advertisement[offer_type][]"]:checked').map( -> $(this).val() ).get(), (n) -> n).join(',')
    categories = $.grep($('[name="advertisement[category][]"]:checked').map( -> $(this).val() ).get(), (n) -> n).join(',')
    params['offer_types'] = offer_types
    params['categories'] = categories
    params['editable'] = false
  $.getScript(
    Routes.get_locations_advertisements_path(params),
    ->
      if callback
        callback()
  )
  return

$(".location-button").livequery ->
  $(this).addClass "active" if $("input[value=#{$(this).attr('lid')}]").length > 0
  return

$('.GetChildren').livequery ->
  $(this).click getChildren
  return

drop_down_button = (multi, editable, lid, value, name)->

  "<div class ='form-group form-group-location'>
    <div class='form-group location-group btn-group' data-toggle='buttons' multi='#{multi}' editable='#{editable}'>
      <div class='btn btn-default #{button_size(name)} loc-btn GetChildren' data-toggle='dropdown' lid='#{lid}' name='#{name}'> #{value} <span class='caret'></span>
      <input type='hidden' name='advertisement[location_ids][]' value='#{lid}'>
      </div>
      <div class='btn btn-default #{button_size(name)} loc-btn DelChildren'>
        <div class='fa fa-times'>
        </div>
      </div>
    </div>
  </div>
  "

easy_button = (multi, editable, lid, value, name)->
  "<div class ='form-group form-group-location'>
     <div class='form-group location-group btn-group' data-toggle='buttons' multi='#{multi}' editable='#{editable}'>
       <div class='btn btn-default #{button_size(name)} loc-btn'  lid='#{lid}' name='#{name}'> #{value}
       <input type='hidden' name='advertisement[location_ids][]' value='#{lid}'>
       </div>
       <div class='btn btn-default #{button_size(name)} loc-btn DelChildren'>
         <div class='fa fa-times'>
         </div>
       </div>
     </div>
    </div>
    "

button_size = (type) ->
  if type =='region' or type == 'city' or type == 'district'
    return ''
  if type == 'street' or 'admin_area' or 'non_admin_area' or 'cottage' or 'garden' or 'complex'
    return 'btn-sm'
  if type == 'street' or 'address' or 'landmark'
    return 'btn-xs'


sort_button_list = (context)->
  children = context.children('.form-group:not(.location-group)')
  list = children.sort (a, b) ->
    text1 = $(a).children('.form-group').children('[lid]').text()
    text2 = $(b).children('.form-group').children('[lid]').text()
    text1  >  text2
  $.each list, (_, value) ->
    context.append(value)

#lid,group, value, multi, has_children, common, parent_id
@click_select_location = (sp) ->
#console.log(sp['name'])
  if sp['el']
    if sp['el'].hasClass('active')
      sp['el'].removeClass('active')
    else
      sp['el'].addClass('active')
  if sp['group'].parent().find("input[value=#{sp['lid']}]").length is 0
    if sp['has_children'] is 'true'
      button = drop_down_button(sp['multi'], sp['editable'], sp['lid'], sp['value'], sp['name'])
    else
      button = easy_button(sp['multi'], sp['editable'], sp['lid'], sp['value'], sp['name'])
    template = sp['group'].parent().append(button)
    sort_button_list(sp['group'].parent())
  else
    sp['group'].parent().find("input[value=#{sp['lid']}]").closest('.location-group').parent().remove()
  if (sp['multi'] is false)
    if (sp['common'] == false)
      $(".GetChildren[lid=#{sp['parent_id']}]").closest('.location-group').parent().find('.location-group').remove()
      sp['group'].parent().append(button)
    else
      $(".location-button.active[lid!=#{sp['lid']}]").click()
      button = sp['group'].parent().find('.GetChildren')
      button.popover "destroy"
      button.removeClass('active')
      button.removeClass('dropdown-toggle')
      getChildren.apply template.find(".GetChildren[lid=#{sp['lid']}]") if template
  loc = $(".last-selected-location").attr('lid')
  $(".last-selected-location").attr('lid',loc + ' ' + sp['lid'])

$('.SelectLocation').livequery ->
  $this = $(this)
  lid = $this.attr('lid')
  $this.click (event)->
    cancelEvent(event)
    sp = {}
    sp['el'] = $this
    sp['lid'] = lid
    sp['name'] = $this.attr('name')
    sp['group'] = $this.closest('.location-group')
    sp['value'] = $this.text()
    sp['multi'] = sp['group'].attr('multi')
    sp['editable'] = sp['group'].attr('editable')
    sp['has_children'] = $this.attr('has_children')
    sp['common'] = true
    sp['parent_id'] = 0
    click_select_location(sp)
    #revalidate anyway
    #sp['el'].closest('form').formValidation('revalidateField', 'location_validation')
    #IF NOT VALID - DO NOT SHOW POPOVER!!!!
    invalid_status = false
    #    vlength = $('form').data('formValidation').$invalidFields.length
    if $('form').data('formValidation')
      $('form').data('formValidation').$invalidFields.each( (i) ->
        if $(this)[i].name is 'location_validation'
          invalid_status = true )

    sp['el'].closest('form').formValidation('revalidateField', 'location_validation')
    if (sp['editable'] is 'true' or ($.trim($this.text()) is 'обл Ростовская') or invalid_status) and (sp['has_children'] is 'true')
      button = $this.closest('.location-group').find('.GetChildren')
      button.popover "destroy"
      button.removeClass('active')
      button.removeClass('dropdown-toggle')
      #in the getChildren callback sp[el] is an empty object!
      sp['el'].closest('form').formValidation('revalidateField', 'location_validation')
      $('form').data('formValidation').$invalidFields.each( (i) ->
        if $(this)[i].name == 'location_validation'
          invalid_status = true )
      if !invalid_status
        getChildren.call($(".GetChildren[lid=#{lid}]"), null)
  if ($.trim($this.text()) is 'обл Ростовская')
    $this.click()
  return

$('.DelChildren').livequery ->
  $(this).click ->
    locationGroup = $(this).closest('.location-group')
    group = locationGroup.parent()
    editable = locationGroup.attr('editable')
    form = group.closest('form')
    group.remove()
    if editable
      form.formValidation('revalidateField', 'location_validation')

$('.location-group[state]').livequery ->
  attr = $(this).attr('state')
  multi = $(this).attr('multi')
  editable = $(this).attr('editable')
  $this = $(this)
  return unless attr
  list = JSON.parse(attr)
  return unless list

  childElements = (element) ->
    return $.grep list, (e) ->
      e.location_id is element.id

  renderElement = (element, context)->
    if element.has_children
      button = $(drop_down_button(multi, editable, element.id, element.title, element.location_type))
    else
      button = $(easy_button(multi, editable, element.id, element.title, element.location_type))

    context.append(button)
    return button

  processElement = (element, context) ->
    new_context = renderElement(element, context)
    has_visible_children = false
    if element.has_children
      $.each childElements(element), (index, value) ->
        has_visible_children = true
        processElement(value, new_context)
    unless has_visible_children
      new_context.find('.btn[lid]').addClass('active')
    #console.log context
    sort_button_list(context)


  root_list = $.grep list, (e) ->
    e.location_id is null

  $.each root_list, (_, value) ->
    processElement(value, $this)

  return


$('.autocomplete-search-location').livequery ->
  $this = $(this)
  for_ = $this.attr('for')
  sp = {}
  sp['parent_id'] = $this.attr('parent_id')
  sp['multi']  = $("input[value=#{sp['parent_id']}]").closest('.location-group').attr('multi')
  sp['editable'] = $("input[value=#{sp['parent_id']}]").closest('.location-group').attr('editable')
  sp['type'] = for_
  parent = $this.parent()
  $this.autocomplete({
    appendTo: parent
    source: (request, response) ->
      $.ajax(
        url: '/api/entity/autocomlite'
        dataType: 'json'
        data:
          term: request.term
          parent_id: sp['parent_id']
          type: sp['type']
        success: (data) ->
          response(data)
          changeSearchButtonStatus(for_)
          return
      )
    select: (event, ui) ->
      cancelEvent(event)
      sp['name'] = for_
      sp['lid'] = ui.item.value
      sp['group'] = $("input[value=#{sp['parent_id']}]").closest('.location-group')
      sp['value'] = ui.item.label
      sp['has_children'] = "#{ui.item.has_children}"
      #      if sp['editable'] is 'true'
      #        $this.closest('form').formValidation('revalidateField', 'location_validation')

      sp['common'] = false
      click_select_location(sp)
      geoCoding()
      $this.val('')

      $this.closest('form').formValidation('revalidateField', 'location_validation')
      invalid_status = false
      $('form').data('formValidation').$invalidFields.each( (i) ->
        if $(this)[i].name == 'location_validation'
          invalid_status = true )
      #      console.log('we revalidate fields =  ' + invalid_status)

      if sp['editable'] is 'true' && sp['has_children'] is 'true'
        button = $this.closest('.location-group').find('.GetChildren')
        button.popover "destroy"
        button.removeClass('active')
        button.removeClass('dropdown-toggle')
        if !invalid_status
          getChildren.call($(".GetChildren[lid=#{sp['lid']}]"))

      #      if sp['editable'] is 'true'
      #        $this.closest('form').formValidation('revalidateField', 'location_validation')
      return false
  })
  $this.focus()


changeSearchButtonStatus = (for_)->
  emptyList = ($(".search-container-action[for=#{for_}] .SelectLocation:visible").length > 0)
  emptyQuery = $.trim($(".search-or-create-location-action[for=#{for_}]").val()) is ""
  emptyAutoComplite = ($(".search-or-create-location-action[for=#{for_}]").hasClass('autocomplete-search-location') and ($(".search-or-create-location-action[for=#{for_}]").parent().find('ul.ui-autocomplete li.ui-menu-item:visible').length > 0))
  notFullQueryAutoComplite = ($(".search-or-create-location-action[for=#{for_}]").hasClass('autocomplete-search-location') and $.trim($(".search-or-create-location-action[for=#{for_}]").val()).length <=2 )


  if emptyList or emptyQuery or emptyAutoComplite or notFullQueryAutoComplite
    $(".create-location-action[for=#{for_}]").addClass('hidden').addClass('disabled')
    $(".empty-search-container-action[for=#{for_}]").addClass('hidden')
  else
    $(".create-location-action[for=#{for_}]").removeClass('hidden').removeClass('disabled')
    $(".empty-search-container-action[for=#{for_}]").removeClass('hidden')

$('.search-or-create-location-action').livequery ->
  for_ = $(this).attr('for')
  $(this).keyup (event)->
    cancelEvent(event)
    query = $(this).val()
    unless ($.trim(query) is "") or (query is $(this).attr("placeholder"))
      $.each $(".search-container-action[for=#{for_}] .SelectLocation"), (index, value) ->
        if $(value).is(":icontains('" + query + "')")
          $(value).show()
        else
          $(value).hide()
        return
    else
      $(".search-container-action[for=#{for_}] .SelectLocation").show()
    changeSearchButtonStatus(for_)
    return
  changeSearchButtonStatus(for_)

$('.create-location-action').livequery ->
  $this = $(this)
  for_ = $(this).attr('for')
  $this.click ->
    $.ajax(
      type: 'POST'
      dataType: 'json'
      url: Routes.api_locations_path()
      data:
        'location[title]': $("[name='location[title]'][for=#{for_}]").val()
        'location[location_type]': $("[name='location[location_type]'][for=#{for_}]").val()
        'location[location_id]': $("[name='location[location_id]'][for=#{for_}]").val()
      success: (data) ->
        context = $(".search-container-action[for=#{for_}]")
        $("[name='location[title]'][for=#{for_}]").val('').keyup()
        template = "<div class='location-button button btn btn-default SelectLocation' has_children='#{data.has_children}' lid='#{data.id}' name='#{data.location_type}'>#{data.title}</div>"
        context.append(template)
        children = context.children('.SelectLocation')
        list = children.sort (a, b) ->
          text1 = $(a).text()
          text2 = $(b).text()
          text1  >  text2
        $.each list, (_, value) ->
          context.append(value)
        el = $(".SelectLocation[lid='#{data.id}']")
        sp = {}
        sp['el'] = el
        sp['lid'] = el.attr('lid')
        sp['group'] = el.closest('.location-group')
        sp['value'] = el.text()
        sp['multi'] = sp['group'].attr('multi')
        sp['editable'] = sp['group'].attr('editable')
        sp['has_children'] = el.attr('has_children')
        sp['common'] = true
        sp['parent_id'] = 0
        sp['name'] = 'address'
        click_select_location(sp)
        changeSearchButtonStatus(for_)
        geoCoding()
        return


    )