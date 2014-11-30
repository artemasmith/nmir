$().ready ->
  $('.location_hide_action').addClass('hidden')

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





@map = (el, latitude = null, longitude = null, editable = true) ->

  start = null

  create_start = (map, x, y) ->
    placemark = new ymaps.Placemark([x, y],
      {hintContent: 'Местоположение объекта'},
      {draggable: true});
    placemark.events.add 'dragend', (e) ->
      coords = e.get('target').geometry.getCoordinates()
      $('.latitude-value').val(coords[0].toPrecision(6))
      $('.longitude-value').val(coords[1].toPrecision(6))
      return
    map.geoObjects.add placemark
    return placemark

  create_map = (center, maxZoom = false)->
      zoom = if maxZoom then 16 : 12
      window.map = new ymaps.Map("map"
        center: center
        zoom: zoom
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
        create_map [latitude, longitude], true
      return
    ymaps.ready init
    return

  $('.SelectLocation, .DelChildren').livequery ->
    $(this).click ->
      position = $.grep($("div:not(.SelectLocation)[lid]").map(->
          $.trim $(this).text()
        ), (n) ->
        n isnt "Выбрать" and n
      ).join " "
      if position and window.map and window.ymaps
        ymaps.geocode(position).then (res) ->
          first = res.geoObjects.get(0)
          if first
            center = first.geometry.getCoordinates()
            map.panTo(center)
            if(start)
              start.geometry.setCoordinates(coords)
            else
              start = create_start(map, coords[0].toPrecision(6), coords[1].toPrecision(6))
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
  $this = $(this)
  $.getScript(
    Routes.get_locations_advertisements_path(parent_id: $this.attr('lid'))
  )

  return

$(".location-button").livequery ->
  $(this).addClass "active" if $("input[value=#{$(this).attr('lid')}]").length > 0
  return

$('.GetChildren').livequery ->
  $(this).click getChildren
  return

drop_down_button = (multi, lid, value)->

  "<div class ='form-group form-group-location'>
    <div class='form-group location-group btn-group' data-toggle='buttons' multi='#{multi}'>
      <div class='btn btn-default GetChildren' data-toggle='dropdown' lid='#{lid}'> #{value} <span class='caret'></span>
      <input type='hidden' name='advertisement[location_ids][]' value='#{lid}'>
      </div>
      <div class='btn btn-default DelChildren'>
        <div class='fa fa-times'>
        </div>
      </div>
    </div>
  </div>
  "

easy_button = (multi, lid, value)->
  "<div class ='form-group form-group-location'>
     <div class='form-group location-group btn-group' data-toggle='buttons' multi='#{multi}'>
       <div class='btn btn-default active btn-xs'  lid='#{lid}'> #{value}
       <input type='hidden' name='advertisement[location_ids][]' value='#{lid}'>
       </div>
       <div class='btn btn-default active btn-xs DelChildren'>
         <div class='fa fa-times'>
         </div>
       </div>
     </div>
    </div>
    "

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
  if sp['el']
    if sp['el'].hasClass('active')
      sp['el'].removeClass('active')
    else
      sp['el'].addClass('active')
  if sp['group'].parent().find("input[value=#{sp['lid']}]").length is 0
    if sp['has_children'] is 'true'
      button = drop_down_button(sp['multi'], sp['lid'], sp['value'])
    else
      button = easy_button(sp['multi'], sp['lid'], sp['value'])
    template = sp['group'].parent().append(button)
    sort_button_list(sp['group'].parent())
  else
    sp['group'].parent().find("input[value=#{sp['lid']}]").closest('.location-group').parent().remove()
  if (sp['multi'] is 'false')
    if (sp['common'] == false)
      $(".GetChildren[lid=#{sp['parent_id']}]").closest('.location-group').parent().find('.location-group').remove()
      sp['group'].parent().append(button)
    else
      $(".location-button.active[lid!=#{sp['lid']}]").click()
      sp['group'].parent().find('.GetChildren').popover "destroy"
      getChildren.apply template.find(".GetChildren[lid=#{sp['lid']}]") if template


@make_active_last_button = (sp)->
  $('.button.loc').removeClass('active')
  sp['group'].find('.button.loc[lid='+sp['lid']+']').addClass( ' active')



$('.SelectLocation').livequery ->
  $(this).click (event)->
    cancelEvent(event)
    sp = {}
    sp['el'] = $(this)
    sp['lid'] = $(this).attr('lid')
    sp['group'] = $(this).closest('.location-group')
    sp['value'] = $(this).text()
    sp['multi'] = sp['group'].attr('multi')
    sp['has_children'] = $(this).attr('has_children')
    sp['common'] = true
    sp['parent_id'] = 0
    click_select_location(sp)




$('.NewAdv').livequery ->
  $(this).click ->
    console.log('hid' + hid)
    console.log('val' + val)
    $('.NewAdv[hid="' + hid + '"]').removeClass('active')
    $('.NewAdv[value="' + val + '"][hid="' + hid + '"]').addClass('active')

$('.DelChildren').livequery ->
  $(this).click ->
    group = $(this).closest('.location-group').parent()
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
    console.log context
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
  $(this).keyup check_phones

$('.DuplicatePhones').livequery ->
  $(this).click ->
    $(".modal#dublicate_modal").modal('show');

$('.ShowAdvPhone').livequery ->
  $this = $(this)
  $this.click ->
    $.ajax(
      url: Routes.api_advertisement_path($('.ShowAdvPhone').data('id'))
      dataType: 'json'
    ).done (data)->
      span =
        $this.replaceWith("<div class=\"btn btn-default btn-xs\">#{data.phone}</div>")
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

#$(".location-button").livequery ->
#  $(this).addClass "active" if $("input[value=#{$(this).attr('lid')}]").length > 0
#  return

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
  sp = {}
  sp['parent_id'] = $(this).attr('parent_id')
  sp['multi']  = $("input[value=#{sp['parent_id']}]").closest('.location-group').attr('multi')
  $(this).autocomplete({
    source: (request, response) ->
      $.ajax(
        url: '/api/entity/streets_houses'
        dataType: 'json'
        data:
          term: request.term
          parent_id: sp['parent_id']
        success: (data) ->
          response(data)
          return
      )
    open: ->
      $(".ui-autocomplete").css("z-index", "2147483647")
    select: (event, ui) ->
      sp['lid'] = ui.item.value
      sp['group'] = $("input[value=#{sp['parent_id']}]").closest('.location-group')
      sp['value'] = ui.item.label
      sp['has_children'] = "#{ui.item.has_children}"
      sp['common'] = false
      click_select_location(sp)
    })

$('input[type="text"][valid-type=integer]').livequery ->
  $(this).forceNumericOnly()


$('input[type="text"][valid-type=float]').livequery ->
  $(this).forceFloatOnly()















