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
  hid = this.getAttribute('hid')
  multi = this.getAttribute('multi')
  value = this.getAttribute('value')
  set_property(hid, multi, value)
  adv_type = $('.adv-type-value').val()
  property = $('.property-type-value').val()
  if adv_type && property
    category = $('input:checked[name*="category"]').val()
    pdata =
      category: category
      adv_type: adv_type
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





@map = (el, latitude = null, longitude = null, editable = true)->

  create_start = (map, x, y) ->
    start = new ymaps.Placemark([x, y],
      {hintContent: 'Местоположение объекта'},
      {draggable: true});
    start.events.add 'dragend', (e) ->
      coords = e.get('target').geometry.getCoordinates()
      $('.latitude-value').val(coords[0].toPrecision(6))
      $('.longitude-value').val(coords[1].toPrecision(6))
      return
    map.geoObjects.add start
    return start

  create_map = (center)->
      start = null
      window.map = new ymaps.Map("map"
        center: center
        zoom: 12
      )

      if latitude and longitude
        start = create_start(map, parseFloat(latitude), parseFloat(longitude))


      if editable
        map.events.add "click", (e) ->
          coords = e.get("coords")
          $('.latitude-value').val(coords[0].toPrecision(6))
          $('.longitude-value').val(coords[1].toPrecision(6))

          if(start)
            start.geometry.setCoordinates(coords)
          else
            start = create_start(map, coords[0].toPrecision(6), coords[1].toPrecision(6))
          return


  $.getScript "http://api-maps.yandex.ru/2.1/?lang=ru_RU", ->
    init = ->
      if !latitude or !longitude
        ymaps.geocode("Ростов-на-Дону").then (res) ->
          center = res.geoObjects.get(0).geometry.getCoordinates()
          create_map(center)
          return
      else
        create_map [latitude, longitude]
      return
    ymaps.ready init
    return
  return


@check_phones = ->
  name = $('input[name="advertisement[user_attributes][name]"]').val()
  phones = $.grep($('input[name*="[original]"]').map( -> $.trim($(this).val()) ).get(), (n) -> n).join(',')

  if phones.length is 0 or name.length is 0
    $(".top-right").notify(
      type: "danger"
      message:
        text: "Необходимо заполнить имя и хоть один номер телефона"
      fadeOut:
        delay: 5000
    ).show()
    return
  $.ajax(
    type: 'GET'
    url: Routes.check_phone_advertisements_path()
    data:
      phones: phones
    dataType: 'script'
  )
  return

@getChildren = ->
  $.getScript(
    Routes.get_locations_advertisements_path
      parent_id: $(this).attr('lid')
  )
  return

$('.GetChildren').livequery ->
  $(this).click getChildren
  return

drop_down_button = (multi, lid, value)->
  "<div class='location-group' multi='#{multi}'><div class='button btn dropdown-toggle btn-default GetChildren' data-toggle='dropdown' lid='#{lid}'> #{value} <span class='caret'></span>&nbsp;<span class='fa fa-times DelChildren'></span><input type='hidden' name='advertisement[location_ids][]' value='#{lid}'></div></div>"

easy_button = (multi, lid, value)->
  "<div class='location-group' multi='#{multi}'><div class='button btn btn-default active btn-xs'  lid='#{lid}'> #{value} <span class='fa fa-times DelChildren'></span><input type='hidden' name='advertisement[location_ids][]' value='#{lid}'></div></div>"

sort_button_list = (context)->
  parent = context.parent()
  list = parent.children('.location-group').sort (a, b) ->
    parseInt($(a).children('[lid]').attr('lid')) > parseInt($(b).children('[lid]').attr('lid'))
  $.each list, (_, value) ->
    parent.append(value)

$('.SelectLocation').livequery ->
  $(this).click ->
    lid = $(this).attr('lid')
    group = $(this).closest('.location-group')
    value = $(this).text()
    multi = group.attr('multi')
    if group.find("input[value=#{lid}]").length is 0
      if $(this).attr('has_children') is 'true'
        button = drop_down_button(multi, lid, value)
      else
        button = easy_button(multi, lid, value)
      template = group.append(button)
      sort_button_list(group.children('.GetChildren'))
    else
      group.find("input[value=#{lid}]").closest('.location-group').remove()
    if (multi is 'false')
      $(".location-button.active[lid!=#{lid}]").click()
      group.find('.GetChildren').popover "destroy"
      getChildren.apply template.find(".GetChildren[lid=#{lid}]") if template
$('.location_hide_action').livequery ->
  $(this).addClass('hidden')

$('.DelChildren').livequery ->
  $(this).click ->
    group = $(this).closest('.location-group')
    group.remove()

$('.location-group[state]').livequery ->
  attr = $(this).attr('state')
  multi = $(this).attr('multi')
  $this = $(this)
  return unless attr
  list = JSON.parse(attr)
  return unless list

  childElements = (element) ->
    return $.grep list, (e) ->
      e.location_id is element.id

  renderElement = (element, context)->
    if element.has_children
      button = $(drop_down_button(multi, element.id, element.title))
    else
      button = $(easy_button(multi, element.id, element.title))

    context.append(button)
    return button

  processElement = (element, context) ->
    new_context = renderElement(element, context)
    if element.has_children
      $.each childElements(element), (index, value) ->
        processElement(value, new_context)
    sort_button_list(context)

  root_list = $.grep list, (e) ->
    e.location_id is null

  $.each root_list, (_, value) ->
    processElement(value, $this)



  return

$('.AdvProperty').livequery ->
  $(this).change prepare_allowed_attributes

$('.AdvPropertySearch').livequery ->
  $(this).change set_adv_property

$('.checkPhone').livequery ->
  $(this).click check_phones

$('.ShowAdvPhone').livequery ->
  $this = $(this)
  $this.click ->
    $.ajax(
      url: Routes.api_advertisement_path($('.ShowAdvPhone').data('id'))
      dataType: 'json'
    ).done (data)->
      span =
        $this.replaceWith("<span>#{data.phone}</span>")
      return
    .error ->
      $(".top-right").notify(
        type: "danger"
        message:
          text: "Ошибка сети("
        fadeOut:
          delay: 5000
      ).show()
    return
  return

$('.dropdown-menu').find('form').livequery ->
  $(this).click ->
    e.stopPropagation()

$('#map').livequery ->
  map($(this),
      $(this).data('latitude'),
      $(this).data('longitude'),
      $(this).prop('editable')
  )


$('form').livequery ->
  $(this).bootstrapValidator({
    feedbackIcons: {
      valid: 'glyphicon glyphicon-ok'
      invalid: 'glyphicon glyphicon-remove'
      validating: 'glyphicon glyphicon-refresh'
    }
  })

$("html").on "mouseup", (e) ->
  unless $(e.target).closest(".popover").length
    $(".popover").each ->
      $(@previousSibling).popover "destroy"
      return
  return

$(".location-button").livequery ->
  $(this).addClass "active" if $("input[value=#{$(this).attr('lid')}]").length > 0
  return

$('form .attributes input, form .attributes textarea').livequery ->
  $this = $(this)
  unless $this.attr('data-bv-field')
    $(this).closest('form').bootstrapValidator('addField', $(this))

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
    },
    (dstart, dend) ->
      $('.range_date_picker_input').val(dstart.format('DD/MM/YYYY')  + ' - ' + dend.format('DD/MM/YYYY'))

  )

$('.use_user_action').livequery ->
  $(this).click ->
    $('.adv-params').removeClass('hidden');
    $('.user-params').addClass('hidden');
    $('#dublicate_modal').modal('hide');
$('.new_entity_action').livequery ->
  $(this).click ->
    location.href = Routes.new_advertisement_path()

$('.SelectLocation, .DelChildren').livequery ->
  $(this).click ->
    position = $.grep($("div:not(.SelectLocation)[lid]").map(->
        $.trim $(this).text()
    ), (n) ->
        n isnt "Выбрать" and n
    ).join " "
    if position and window.map
      ymaps.geocode(position).then (res) ->
        first = res.geoObjects.get(0)
        if first
          center = first.geometry.getCoordinates()
          map.panTo(center)
          return















