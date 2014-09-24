#hid - hid of the element, multi - bool flag of multi value saving, oval - originan value we've setted up
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


@show_adv_phone = ->
  $.ajax(
      url: Routes.api_advertisement_path($('.ShowAdvPhone').data('id'))
      dataType: 'json'
    ).done (data)->
      span =
      $('.ShowAdvPhone').replaceWith("<span>#{data.name} #{data.phone}</span>")
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
      map = new ymaps.Map("map"
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
  $.ajax(
    type: 'GET'
    url: Routes.check_phone_advertisements_path()
    data:
      phones: $('input[name="original"]').map( ->
        $(this).val()).get().join(',')
      email: $('input[name*="email"]').val()
    dataType: 'script'
  )
  return

####LOCATION HADLING

@set_location = (hid, value, multi) ->
  if multi=='checkbox'
    res = $(hid).val().replace(value,'')
    $(hid).val(res + ' ' + value)
  else
    $(hid).val(value)
  return

@delete_child = ->
  lid = this.getAttribute('lid')
  $('.btn-group[lid=' + lid + ']').html('')
  $('.check-button[lid=' + lid + ']').html('')
  $.ajax(
    type: 'GET'
    dataType: 'script'
    url: Routes.add_child_locations_advertisements_path()
    data:
      locations: $(".location-button:checked").map( ->
        $(this).val()).get().join(',')
      multi: this.getAttribute('multi')
  )
  return

@select_locations = ->
  ltype = this.getAttribute('ltype')
  locations = $(".location-button:checked")
  multi = locations[0].getAttribute('type')
  $.ajax(
    type: 'GET'
    dataType: 'script'
    url: Routes.add_child_locations_advertisements_path()
    data:
      locations: $(".location-button:checked").map( ->
        $(this).val()).get().join(',')
      multi: this.getAttribute('multi')
  )
  $('.location-select-modal').modal('hide')
  #set location_id in hidden fields

  for i in [0..locations.length-1]
    hid = '.'+locations[i].getAttribute('name')+'-id'
    if multi == 'checkbox'
      old_val = $(hid).val().replace($(locations[i]).val())
      $(hid).val(old_val + ' ' + $(locations[i]).val())
    else
      $(hid).val($(locations[i]).val())

  return

@get_children = ->
  $.ajax(
    type: 'GET'
    dataType: 'script'
    url: Routes.get_locations_advertisements_path()
    data:
      parent_id: this.getAttribute('lid')
      multi: this.getAttribute('multi')
  )
  return


@set_auto_location =(elem) ->
  $('.autocomplete.location-button').val($(elem.val()))
  $('.autocomplete.location-button')[0].setAttribute('checked', true)
  return

####ENDOF LOCATION HANDLING

$('.autocomplete-search-location').livequery ->
  $(this).autocomplete
    source: Routes.api_advertisements_path()
    minChars: 2
    params: ->
      parent_id: $(this)[0].getAttribute('parent_id')
    select: ->
      set_auto_location(this)

$('.GetChildren').livequery ->
  $(this).click get_children

$('.DeleteElem').livequery ->
  $(this).click delete_child

$('.SelectLocation').livequery ->
  $(this).click select_locations

$('.SelectRegion').livequery ->
  $(this).click select_region

$('.SelectDistrict').livequery ->
  $(this).click select_district

$('.AdvProperty').livequery ->
  $(this).change prepare_allowed_attributes

$('.AdvPropertySearch').livequery ->
  $(this).change set_adv_property

$('.checkPhone').livequery ->
  $(this).click check_phones

$('.ShowAdvPhone').livequery ->
  $(this).click show_adv_phone

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





