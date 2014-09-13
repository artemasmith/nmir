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
  adv_type = $('.adv-type-value')[0].value
  property = $('.property-type-value')[0].value
  if adv_type && property
    category = $(':input:checked[name="advertisement[category]"]')[0].value
    pdata =
      category: category,
      adv_type: adv_type
    $.ajax
      type: 'POST',
      url: "get_attributes",
      data: pdata

  return

@set_adv_property = ->
  hid = this.getAttribute('hid')
  multi = this.getAttribute('multi')
  value = this.getAttribute('value')
  set_property(hid, multi, value)
  return

@select_district = ->
  mv = this.getAttribute("mv")
  cities = $(".active.ClickDistrict")
  rescity = ""
  $("#" + mv).modal "hide"
  i = 0
  while i < cities.length
    rescity += cities[i].textContent + " "
    i++
  $("#city-select-button")[0].textContent = rescity
  return

@get_name = (radio) ->
  if radio == 'checkbox'
    return 'district[]'
  else
    return 'advertisement[district_id]'

@select_region =(radio) ->
  #selected_regions = $("#city-select")[0].getAttribute("value")
  selected_regions = ''
  regions = $(':input:checked[name*="city_id"]')
  $.each regions, (i,rg) ->
    selected_regions += ' ' + rg.value
    return
  cities = ""
  $.ajax
    dataType: "json"
    url: "/locations?parents=" + selected_regions
    success: (data) ->
      $("#region-select-modal").modal "hide"
      regions = ""
      resulthtml = ""
      for region of data
        resulthtml += "<span>" + region + "</span><p><div class=\"btn-group\" data-toggle=\"buttons\">"
        regions += region + " "
        cities = data[region]
        i = 0
        while i < cities.length
          resulthtml += "<button type=\"button\" district=\"" + cities[i][1] + "\" class=\"btn btn-default ClickDistrict\" \" ><input name=\"" + get_name(radio) + "\" type=\"" + radio + "\" value=\"" + cities[i][1] + "\">" + cities[i][0] + "</input></button>"
          i++
        resulthtml += "</div><p>"
      $("#cities-list").html resulthtml
      $("#region-select-button")[0].textContent = regions
      return

  return


@submit_form = (e) ->

  #Do required stuff for setting up search credentials (we are looking for .active elements)
  $(".super-form").trigger "submit.rails"
  return

@show_adv_phone = ->
  console.log('fire')
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



@render_map = (el)->
  url = "http://api-maps.yandex.ru/2.1/?lang=ru_RU"
  $.getScript url, ->
    init = ->
      new ymaps.Map("map",
        center: [
          el.data('latitude')
          el.data('longitude')
        ]
        zoom: 7
      )
      return
    ymaps.ready init

@render_pointed_map = (el)->
  url = "http://api-maps.yandex.ru/2.1/?lang=ru_RU"
  $.getScript url, ->
    init = ->
      start = null

      map = new ymaps.Map("pointed_map"
        center: [55.76, 37.64]
        zoom: 7
      )

      map.events.add "click", (e) ->
        coords = e.get("coords")
        console.log coords
        $('.latitude-value').val(coords[0].toPrecision(6))
        $('.longitude-value').val(coords[1].toPrecision(6))

        if(start)
          start.geometry.setCoordinates(coords)
        else
          start = new ymaps.Placemark(coords, { iconContent: 'А' }, { draggable: false });
#          start.events.add('dragend', this._onDragEnd, this);

        return
    ymaps.ready init
    return
  return




#selectors

@ready = ->
  $('.dropdown-menu').find('form').click ->
    e.stopPropagation()
  $('.SelectRegion').on('click', select_region)
  $('.SelectDistrict').on('click', select_district)
  $('.AdvProperty').on('change', prepare_allowed_attributes)
  $('.AdvPropertySearch').on('change', set_adv_property)
  return

$('.ShowAdvPhone').livequery ->
  $(this).click show_adv_phone

$('#map').livequery ->
  render_map($(this))

$('#pointed_map').livequery ->
  render_pointed_map($(this))

$('form').livequery ->
  $(this).bootstrapValidator({
    feedbackIcons: {
      valid: 'glyphicon glyphicon-ok'
      invalid: 'glyphicon glyphicon-remove'
      validating: 'glyphicon glyphicon-refresh'
    }
  })


$('.fileupload').livequery ->
  $(this).fileupload
    url: Routes.photos_path()
    dataType: 'json'
    disableImageResize: /Android(?!.*Chrome)|Opera/.test(window.navigator.userAgent)
    maxFileSize: 5000000
    acceptFileTypes: /(\.|\/)(gif|jpe?g|png)$/i

  $(this).addClass "fileupload-processing"

  $.ajax(
    url: $(".fileupload").fileupload("option", "url")
    dataType: "json"
    context: $("#fileupload")[0]
  ).always(->
    $(this).removeClass "fileupload-processing"
    return
  ).done (result) ->
    $(this).fileupload("option", "done").call this, $.Event("done"),
      result: result

    return






$(document).on('ready page:load', ready);
