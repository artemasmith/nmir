#oid - hid of the element, multi - bool flag of multi value saving, oval - originan value we've setted up
@set_property = (oid, multi, oval) ->
  val = ''
  sid = ''
  if (oid == 'category-value')
    sid = '#property-type-value'
    if parseInt( oval, 10 ) <= 5 then val = 1 else val = 0
  if (oid == 'offer-type-value')
    sid = '#adv-type-value'
    if oval == '0' || oval == '2' || oval == '3' then val = 1 else val = 0
  if multi
    val = $(sid)[0].getAttribute('value') + ' ' + val
  $(sid)[0].setAttribute('value', val)
  return

@set_hidden_multi = ->
  cn = this.className
  hid = this.getAttribute("hid")
  value = this.getAttribute("value")
  rv = ""
  current_value = $("#" + hid)[0].getAttribute("value")
  unless cn.match("active")
    rv = current_value + " " + value
  else
    rv = current_value.replace(value, "")
  $("#" + hid)[0].setAttribute "value", rv
  set_property(hid, true, value)
  return

@set_hidden_one =  ->
  hid = this.getAttribute("hid")
  value = this.getAttribute("value")
  $("#" + hid)[0].setAttribute "value", value
  set_property(hid, false, value)
  return

@click_region =  ->
  cn = this.className
  rg = this.getAttribute("region")
  city_value = this.getAttribute("city")
  selected_regions = $("#region-select")[0].getAttribute("value")
  selected_cities = $("#city-select")[0].getAttribute("value")
  unless cn.match("active")
    rg = selected_regions + " " + rg
    city_value = selected_cities + " " + city_value
  else
    rg = selected_regions.replace(rg, "")
    city_value = selected_cities.replace(city_value, "")

  #Do I need to save region?
  $("#region-select")[0].setAttribute "value", rg
  $("#city-select")[0].setAttribute "value", city_value
  return


@click_district = (e) ->
  cn = e.className
  district = e.getAttribute("district")
  selected_cities = $("#district-select")[0].getAttribute("value")
  unless cn.match("active")
    district = selected_cities + " " + district
  else
    district = selected_cities.replace(district, "")
  $("#district-select")[0].setAttribute("value", district)
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


@select_region = ->
  selected_regions = $("#city-select")[0].getAttribute("value")
  cities = ""
  $.ajax
    dataType: "json"
    url: "/locations?parents=" + selected_regions
    success: (data) ->
      $("#region-select-modal").modal "hide"
      regions = ""
      resulthtml = ""
      for region of data
        resulthtml += "<span>" + region + "</span><p>"
        regions += region + " "
        cities = data[region]
        i = 0
        while i < cities.length
          resulthtml += "<span><button  district=\"" + cities[i][1] + "\" class=\"btn btn-default ClickDistrict\" onclick=\"click_district(this);\"data-toggle=\"buttons\" \">" + cities[i][0] + "</button></span>"
          i++
        resulthtml += "<p>"
      $("#cities-list").html resulthtml
      $("#region-select-button")[0].textContent = regions
      return

  return

#REFACTOR and DRY it
@select_only_region = ->
  selected_regions = $("#city-select")[0].getAttribute("value")
  cities = ""
  $.ajax
    dataType: "json"
    url: "/locations?parents=" + selected_regions
    success: (data) ->
      $("#region-select-modal").modal "hide"
      regions = ""
      resulthtml = ""
      for region of data
        resulthtml += "<span>" + region + "</span><p>"
        regions += region + " "
        cities = data[region]
        i = 0
        while i < cities.length
          resulthtml += "<span class=\"btn-group \" data-toggle=\"buttons\"><button  district=\"" + cities[i][1] + "\" class=\"btn btn-default ClickDistrict\"></button><input type=\"radio\"></input>" + cities[i][0] + "</span>"
          i++
        resulthtml += "<p>"
      $("#cities-list").html resulthtml
      $("#region-select-button")[0].textContent = regions
      return
  return

@select_only_district = ->
  mv = this.getAttribute("mv")
  $("#" + mv).modal "hide"
  dts = $('.active.ClickDistrict')[0]
  $('#district-select')[0].setAttribute('value', dts.getAttribute('district'))
  return


@submit_form = (e) ->

  #Do required stuff for setting up search credentials (we are looking for .active elements)
  $(".super-form").trigger "submit.rails"
  return

#selectors

@selectors =
  SetHideMulti: set_hidden_multi,
  SetHideOne: set_hidden_one,
  ClickRegion: click_region,
  ClickDistrict: click_district,
  SelectDistrict: select_district,
  SelectRegion: select_region,
  SelectOnlyRegion: select_only_region,
  SelectOnlyDistrict: select_only_district

@ready = ->
  $('.SetHideMulti').on('click', set_hidden_multi)
  $('.SetHideOne').on('click', set_hidden_one)
  $('.ClickRegion').on('click', click_region)
  #$('.ClickDistrict').on('click', click_district)
  $('.SelectRegion').on('click', select_region)
  $('.SelectDistrict').on('click', select_district)
  return

#setting up onclick events
$(document).ready(ready())
$(document).on('ready page:load', ready);