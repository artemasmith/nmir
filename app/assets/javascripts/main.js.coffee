$().ready ->
  $('.control_hide_action').addClass('hidden')
  $('.control_show_action').removeClass('hidden')
  $('.control_remove_action').remove()


@set_property = (hid, multi, oval) ->
  val = ''
  sid = ''
  if (hid == 'category')
    sid = '.property-type-value'
    if parseInt( oval, 10 ) <= 5 then val = 'residental' else val = 'commerce'
  if (hid == 'offer')
    sid = '.adv-type-value'
    if oval == '0' || oval == '2' || oval == '3' then val = 'offer' else val = 'demand'
  if multi == "multi"
    val = 0
    val = 1 if val == "offer" || val == "residental"
    val = $(sid)[0].getAttribute('value').replace(val,'') + ' ' + val
  $(sid)[0].setAttribute('value', val)
  return

@prepare_allowed_attributes = ->
  $this = $(this)
  hid = $this.attr('hid')
  multi = $this.attr('multi')
  value = $this.attr('value')


  $('.AdvProperty[hid="' + hid + '"][value!="' + value + '"]').removeClass('active')
  $('.AdvProperty[hid="' + hid + '"][value!="' + value + '"] input').prop('checked', false)
  set_property(hid, multi, value)


  offer_type = $('input:checked[name*="offer_type"]').val()
  category = $('input:checked[name*="category"]').val()
  if offer_type && category
    pdata =
      category: category
      offer_type: offer_type
    $.ajax
      type: 'GET',
      url: Routes.get_attributes_advertisements_path(),
      data: pdata

  return

@set_adv_property = ->
  hid = this.getAttribute('hid')
  multi = this.getAttribute('multi')
  value = this.getAttribute('value')
  set_property(hid, multi, value)
  return

@create_start = (map, x, y, editable) ->
  placemark = new ymaps.Placemark([x, y],
    {hintContent: 'Местоположение объекта'},
    {draggable: editable})
  if editable
    placemark.events.add 'dragend', (e) ->
      coords = e.get('target').geometry.getCoordinates()
      $('.latitude-value').val(coords[0].toPrecision(6))
      $('.longitude-value').val(coords[1].toPrecision(6))
      $('.zoom-value').val(map.getZoom())
      return
  map.geoObjects.add placemark
  return placemark

@position_map = (with_admin_area)->
  $.grep($("div:not(.SelectLocation)[lid]").map(->
      if (!with_admin_area && ($(this).attr('name') isnt 'non_admin_area') and ($(this).attr('name') isnt 'admin_area')) or with_admin_area
        $.trim $(this).text()
      else
        null
    ), (n) ->
    (n isnt "Выбрать") and (n isnt "Место") and (n isnt "нажмите чтобы выбрать") and n
  )

@geoCoding = ->
  return unless $('#map').data('editable')
  position = @position_map(false).join " "
  if position and window.map and window.ymaps
    ymaps.geocode(position).then (res) ->
      first = res.geoObjects.get(0)
      if first
        center = first.geometry.getCoordinates()
        map.setCenter(center)
        map.setZoom(16)
        start = map.geoObjects.get(0)
        if start
          start.geometry.setCoordinates(center)
          $('.latitude-value').val(center[0].toPrecision(6))
          $('.longitude-value').val(center[1].toPrecision(6))
          $('.zoom-value').val(map.getZoom())
        else
          start = create_start(map, center[0], center[1], true)
        return
  return


@map = (el, latitude = null, longitude = null, zoom = null, editable = true) ->
  create_map = (center, zoom)->
      window.map = new ymaps.Map("map",
        center: center
        zoom: parseInt(zoom)
      )

      map.behaviors.disable("scrollZoom")
      map.controls.remove("trafficControl")
      .remove("rulerControl")
      .remove("fullscreenControl")
      .remove("typeSelector")
      .remove("geolocationControl")


      if latitude and longitude
        create_start(map, parseFloat(latitude), parseFloat(longitude), editable)

      if editable
        map.events.add "click", (e) ->
          coords = e.get("coords")
          $('.latitude-value').val(coords[0].toPrecision(6))
          $('.longitude-value').val(coords[1].toPrecision(6))
          $('.zoom-value').val(map.getZoom())
          start = map.geoObjects.get(0)
          if start
            start.geometry.setCoordinates(coords)
          else
            start = create_start(map, coords[0].toPrecision(6), coords[1].toPrecision(6), editable)
          return



  $.getScript "http://api-maps.yandex.ru/2.1/?lang=ru_RU", ->
    init = ->
      if !latitude or !longitude
        ymaps.geocode("Ростов-на-Дону").then (res) ->
          center = res.geoObjects.get(0).geometry.getCoordinates()
          create_map(center, zoom)
          return
      else
        create_map([latitude, longitude], zoom)
      return
    ymaps.ready init
    return
  $('.SelectLocation, .DelChildren').livequery ->
    $(this).click ->
      geoCoding()
  return


@check_phones = ->

  name = $('input[name="advertisement[user_attributes][name]"]').val()
  phones = $.grep($('input[name*="[original]"]').map( -> $.trim($(this).val()) ).get(), (n) -> n).join(',')

  #console.log phones
  if phones.length > 3
    $.ajax(
      type: 'GET'
      url: Routes.check_phone_advertisements_path()
      data:
        phones: phones
      dataType: 'script'
    )
  else
    $('.DuplicatePhones').addClass('hidden')
  return

@getChildren = ->
  $this = $(this)
  params = {'parent_id': $this.attr('lid')}
  if $('.click_additional_search_params_action').length > 0
    offer_types = $.grep($('[name="advertisement[offer_type][]"]:checked').map( -> $(this).val() ).get(), (n) -> n).join(',')
    categories = $.grep($('[name="advertisement[category][]"]:checked').map( -> $(this).val() ).get(), (n) -> n).join(',')
    params['offer_types'] = offer_types
    params['categories'] = categories
    params['editable'] = false
  $.getScript(
    Routes.get_locations_advertisements_path(params)
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
      sp['group'].parent().find('.GetChildren').popover "destroy"
      getChildren.apply template.find(".GetChildren[lid=#{sp['lid']}]") if template
  loc = $(".last-selected-location").attr('lid')
  $(".last-selected-location").attr('lid',loc + ' ' + sp['lid'])

@mark_last_selection = (lid) ->
  $('.loc-btn').removeClass('active')
  lids = lid.split(' ')
  for i in [0..(lids.length-1)]
    if lids[i]
      $('.loc-btn[lid=' + lids[i] + ']').parent().find('.loc-btn').addClass( ' active')
  $(".last-selected-location").attr('lid','')

$('.GetChildren').livequery ->
  $(this).on 'hide.bs.popover', ->
    lid = $(".last-selected-location").attr('lid')
    #console.log("lid on hide popover=#{lid}")
    if lid
      mark_last_selection(lid)

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
  if ($.trim($this.text()) is 'обл Ростовская')
    $this.click()
    button = $this.closest('.location-group').find('.GetChildren')
    button.popover "destroy"
    button.removeClass('dropdown-toggle')
    getChildren.call($(".GetChildren[lid=#{lid}]"))
  return

$('.DelChildren').livequery ->
  $(this).click ->
    group = $(this).closest('.location-group').parent()
    group.remove()

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
      new_context.find('.btn').addClass('active')
    #console.log context
    sort_button_list(context)


  root_list = $.grep list, (e) ->
    e.location_id is null

  $.each root_list, (_, value) ->
    processElement(value, $this)



  return

$('#reg-phones').livequery ->
  $(this).find('.dell-phone-number').first().addClass('hidden')
  $(this).find('.add-phone-number').first().removeClass('hidden')
  $(this).on 'nested:fieldAdded', (e) ->
    parent = e.target
    $(parent).find('.add-phone-number').addClass('hidden')
    $(parent).find('.dell-phone-number').removeClass('hidden')
    time = new Date()
    $(parent).find('.form-control').attr('id', "#{time.getMinutes()} #{time.getSeconds()}")
    target_input = $('.phone-target-field ').attr('value')
    $(parent).find('.form-control').attr('name', target_input + "[#{time.getMinutes()}#{time.getSeconds()}][original]")
    return

$('.AdvProperty').livequery ->
  $(this).change prepare_allowed_attributes

$('.AdvPropertySearch').livequery ->
  $(this).change set_adv_property

$('.checkPhone').livequery ->
  $(this).on 'keyup paste', ->
    check_phones()

$('.DuplicatePhones').livequery ->
  $(this).click ->
    $(".modal#dublicate_modal").modal('show');

$('.HideAdvPhone').livequery ->
  $this = $(this)
  n = $this.data('n')
  $this.replaceWith("<div data-n=\"#{n}\" class=\"btn btn-success btn-xs ShowAdvPhone yaSend\" yaparam=\"phone_num_open\" data-phone=\"#{$this.text()}\">показать телефон</div>")
  return

$('.ShowAdvPhone').livequery ->
  $this = $(this)
  $this.popover
    container: 'body'
    html: true
    placement: 'top'

    content: ->
      html = "<p class='lead'>номер телефона "+ $this.data('phone') + "</p>"
      html += "<p>Объявление №" + $this.data('n') + " на сайте мультилистинг су</p>"
      html
  $this.click (event)->
    mark_as_active($this)
    #if $this.hasClass('active') then $this.removeClass('active') else $this.addClass('active')

    $('body').on 'click', (e) ->
      if !$this.is(e.target) and $this.has(e.target).length == 0 and $('.popover').has(e.target).length == 0
        $this.popover 'hide'
        $(".popover").hide()
        $this.removeClass('active')
    cancelEvent(event)
    return


  return


  #    .Anumber data= "Объявление № #{@adv.id}"
  return

$('.dropdown-menu').find('form').livequery ->
  $(this).click ->
    e.stopPropagation()

$('#map').livequery ->
  map($(this),
      $(this).data('latitude'),
      $(this).data('longitude'),
      $(this).data('zoom'),
      $(this).data('editable')
  )



@mark_as_active = (element) ->
  if $(element).hasClass('active') then $(element).removeClass('active') else $(element).addClass('active')
  return


$('.abuse_popover_action').livequery ->
  $this = $(this)
  $this.tooltip
    container: 'body'
    title: "Пожалуйста, поддерживайте чистоту базы!"
    placement: 'top'
  $this.popover
    container: 'body'
    html: true
    placement: 'bottom'
    title: ' '
    template: '<div class="popover popover-medium"><div class="arrow"></div><div class="popover-inner"><h3 class="popover-title style="display: none"></h3><div class="popover-content"><p></p></div></div></div>'
    content: ->
      html = $('.abuse_form_action').html()
      $('.abuse_form_action').remove()
      html
  $this.click (event)->
    mark_as_active($this)
    $('body').on 'click', (e) ->
      if !$this.is(e.target) and $this.has(e.target).length == 0 and $('.popover').has(e.target).length == 0
        $this.popover 'hide'
        $(".popover").hide()
        $this.removeClass('active')
    cancelEvent(event)

    return

  return



$("html").on "mouseup", (e) ->
  unless $(e.target).closest(".popover").length
    $(".popover").each ->
      $(@previousSibling).popover "destroy"
      return
  return

#$(".location-button").livequery ->
#  $(this).addClass "active" if $("input[value=#{$(this).attr('lid')}]").length > 0
#  return



cancelEvent = (event) ->
  event = (event or window.event)
  return false  unless event
  event = event.originalEvent  while event.originalEvent
  event.preventDefault()  if event.preventDefault
  event.stopPropagation()  if event.stopPropagation
  event.cancelBubble = true
  event.returnValue = false
  false

$('a.show_photo_action').livequery ->
  $this = $(this)
  $this.click (e)->
    $('.first_photo_comment_action').text($this.attr('comment'))
    $('.first_photo_img_action').attr('src', $this.attr('full_scr'))
    cancelEvent(e)

$('.range_date_picker_action').livequery ->
  $(this).daterangepicker(
    {
      format: 'DD/MM/YYYY'
      locale: 'ru'
      ranges:
        'За сегодня': [
          moment()
          moment()
        ]
        'За вчера': [
          moment().subtract("days", 1)
          moment().subtract("days", 1)
        ]
        "За неделю": [
          moment().subtract("days", 6)
          moment()
        ]
        "За 30 дней": [
          moment().subtract("days", 29)
          moment()
        ]
        "За месяц": [
          moment().startOf("month")
          moment().endOf("month")
        ]
        "За прошлый месяц": [
          moment().subtract("month", 1).startOf("month")
          moment().subtract("month", 1).endOf("month")
        ]

      startDate: moment().subtract("days", 29)
      endDate: moment()
    },
    (dstart, dend) ->
      $('.range_date_picker_input').val(dstart.format('DD/MM/YYYY')  + ' - ' + dend.format('DD/MM/YYYY'))

  )

$('.use_user_action').livequery ->
  $(this).click ->
    #$('.adv-params').removeClass('hidden');
    #$('.user-params').addClass('hidden');
    $('#dublicate_modal').modal('hide');
$('.new_entity_action').livequery ->
  $(this).click ->
    location.href = Routes.new_advertisement_path()




$('.click_additional_search_params_action').livequery ->
  $(this).change ->
    offer_types = $.grep($('[name="advertisement[offer_type][]"]:checked').map( -> $(this).val() ).get(), (n) -> n).join(',')
    categories = $.grep($('[name="advertisement[category][]"]:checked').map( -> $(this).val() ).get(), (n) -> n).join(',')
    $.getScript Routes.get_search_attributes_advertisements_path({offer_types: offer_types, categories: categories})
    return
  return

$('.autocomplete-search-location').livequery ->
  $this = $(this)
  for_ = $this.attr('for')
  sp = {}
  sp['parent_id'] = $this.attr('parent_id')
  sp['multi']  = $("input[value=#{sp['parent_id']}]").closest('.location-group').attr('multi')
  sp['editable'] = $("input[value=#{sp['parent_id']}]").closest('.location-group').attr('editable')
  parent = $this.parent()
  $this.autocomplete({
    appendTo: parent
    source: (request, response) ->
      $.ajax(
        url: '/api/entity/streets_houses'
        dataType: 'json'
        data:
          term: request.term
          parent_id: sp['parent_id']
        success: (data) ->
          response(data)
          changeSearchButtonStatus(for_)
          return
      )
    select: (event, ui) ->
      cancelEvent(event)
      sp['name'] = 'street'
      sp['lid'] = ui.item.value
      sp['group'] = $("input[value=#{sp['parent_id']}]").closest('.location-group')
      sp['value'] = ui.item.label
      if sp['editable'] is 'true'
        sp['has_children'] = 'true'
      else
        sp['has_children'] = "#{ui.item.has_children}"
      sp['common'] = false
      click_select_location(sp)
      geoCoding()
      #console.log('added lid' + sp['lid'])
      $this.val('')
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

$('[name="advertisement[price_from]"], [name="advertisement[price_to]"]').livequery ->
  $(this).priceFormat({
    prefix: ''
    thousandsSeparator: ' '
    centsLimit: 0
    clearPrefix: true
  })
  $(this).focusout ->
    if $(this).val() is '0'
      $(this).val('')
    return
  return


$('.formatRub').livequery ->
  formatRub = (value) ->
    tab = value.toString().split("")
    result = ""
    j = 0
    i = tab.length - 1
    while i >= 0
      if j is 3
        result = tab[i] + " " + result
        j = 0
      else
        result = tab[i] + result
      j++
      i--
    result
  $(this).text(formatRub($(this).text()))
  return


$('.connected-carousels').livequery ->
  # This is the connector function.
  # It connects one item from the navigation carousel to one item from the
  # stage carousel.
  # The default behaviour is, to connect items with the same index from both
  # carousels. This might _not_ work with circular carousels!

  connector = (itemNavigation, carouselStage) ->
    carouselStage.jcarousel('items').eq itemNavigation.index()

  carouselStage = $('.carousel-stage').jcarousel()
  carouselNavigation = $('.carousel-navigation').jcarousel()
  # We loop through the items of the navigation carousel and set it up
  # as a control for an item from the stage carousel.
  carouselNavigation.jcarousel('items').each ->
    item = $(this)
    # This is where we actually connect to items.
    target = connector(item, carouselStage)
    item.on('jcarouselcontrol:active', ->
      carouselNavigation.jcarousel 'scrollIntoView', this
      item.addClass 'active'
      return
    ).on('jcarouselcontrol:inactive', ->
      item.removeClass 'active'
      return
    ).jcarouselControl
      target: target
      carousel: carouselStage
    return
  # Setup controls for the stage carousel
  $('.prev-stage').on('jcarouselcontrol:inactive', ->
    $(this).addClass 'inactive'
    return
  ).on('jcarouselcontrol:active', ->
    $(this).removeClass 'inactive'
    return
  ).jcarouselControl target: '-=1'
  $('.next-stage').on('jcarouselcontrol:inactive', ->
    $(this).addClass 'inactive'
    return
  ).on('jcarouselcontrol:active', ->
    $(this).removeClass 'inactive'
    return
  ).jcarouselControl target: '+=1'
  # Setup controls for the navigation carousel
  $('.prev-navigation').on('jcarouselcontrol:inactive', ->
    $(this).addClass 'inactive'
    return
  ).on('jcarouselcontrol:active', ->
    $(this).removeClass 'inactive'
    return
  ).jcarouselControl target: '-=1'
  $('.next-navigation').on('jcarouselcontrol:inactive', ->
    $(this).addClass 'inactive'
    return
  ).on('jcarouselcontrol:active', ->
    $(this).removeClass 'inactive'
    return
  ).jcarouselControl target: '+=1'
  return

@send_ya_metrika = (goal) ->
  yaCounter28695786.reachGoal(goal)
  return

$('.yaSend').livequery ->
  $(this).click ->
    send_ya_metrika($(this).attr('yaparam'))
    return


















