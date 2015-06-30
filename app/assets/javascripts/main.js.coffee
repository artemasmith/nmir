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

@position_map = ->
  map = $.grep($("div:not(.SelectLocation)[lid]").map(->
      if ($(this).attr('name') isnt 'non_admin_area') and ($(this).attr('name') isnt 'admin_area') and ($(this).attr('name') isnt 'cottage') and ($(this).attr('name') isnt 'garden') and ($(this).attr('name') isnt 'complex')
        return [[$.trim($(this).text()), $(this).attr('name'), $(this), $(this).attr('lid')]]
      return null
    ), (n) ->
    n and (n[0] isnt "") and (n[0] isnt "Выбрать") and (n[0] isnt "Место") and (n[0] isnt "нажмите чтобы выбрать")
  ).sort (x, y)->
    list = ['region',
    'district',
    'city',
    'street',
    'address'
    ]
    a = list.indexOf(x[1])
    b = list.indexOf(y[1])
    if (a < b)
      return 1
    if (a > b)
      return -1
    return 0
  el = map[0]
  mapGeo = null
  if el
    $el = el[2]
    mapGeo = [el[0]]
    while true
      $el = $el.parents().eq(2).find('.GetChildren:first')
      lid = $el.attr('lid')
      if $el.length > 0 && lid && lid isnt '0'
        inMap = $.grep(map, (e) ->
          e[3] is lid
          ).length > 0
        if inMap
          mapGeo.unshift($.trim($el.text()))
      else
        break
  return mapGeo || ["Ростов-на-Дону"]


@geoCoding = ->
  return unless $('#map').data('editable')
  position = @position_map().join " "
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


$('#reg-phones').livequery ->

  $this = $(this)
  $this.find('.dell-phone-number').first().addClass('hidden')
  $this.find('.add-phone-number').first().removeClass('hidden')
  $this.on 'nested:fieldAdded', (e) ->
    parent = e.target
    $(parent).find('.add-phone-number').addClass('hidden')
    $(parent).find('.dell-phone-number').removeClass('hidden')
    time = new Date()
    $(parent).find('.form-control').attr('id', "#{time.getMinutes()} #{time.getSeconds()}")
    target_input = $('.phone-target-field ').attr('value')
    $(parent).find('.form-control').attr('name', target_input + "[#{time.getMinutes()}#{time.getSeconds()}][original]")
    if $('#reg-phones').find('input:visible').length >= 3
      $this.find('.add-phone-number').addClass('invisible')
  $this.on 'nested:fieldRemoved', (e) ->
    if $('#reg-phones').find('input:visible').length < 3
      $this.find('.add-phone-number').removeClass('invisible')
    return false

$('.AdvProperty').livequery ->
  $(this).change prepare_allowed_attributes

$('.AdvPropertySearch').livequery ->
  $(this).change set_adv_property

$('.checkPhone').livequery ->
  $(this).on 'keyup paste input', ->
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
      html = "<p class='lead'>номер телефона #{$this.data('phone')}</p>"
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
      $(@previousSibling).removeClass('active')
      $(@previousSibling).removeClass('dropdown-toggle')
      return
  return



@cancelEvent = (event) ->
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

      #startDate: moment().subtract("days", 29)
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

$('.createEntity').livequery ->
  $(this).on 'submit', ->
#    alert('dfgdfgdfgdfg')
#    console.log('send ya!')
    send_ya_metrika('entity_submit')


















