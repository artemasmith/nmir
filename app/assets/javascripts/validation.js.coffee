initEmail = ($this) ->
  unless $this.attr('data-fv-field')
    form = $this.closest('form')
    console.log form
    validators =
      emailAddress:
        message: "Пожалуйста, введите email"
      notEmpty:
        message: "Пожалуйста, введите email"

    unless form.hasClass('easyBootstrapValidator')
      validators['remote'] =
        type: 'POST'
        url: Routes.api_validation_index_path()
        message: "Такой email уже зарегистрирован на нашем сайте. <br/><a href='" + Routes.new_user_session_path() + "'>Выполните вход</a>."

    form.formValidation('addField', $this, {
      validators: validators
    })
    form.formValidation('revalidateField', $this.name)


colorLabel = ->
  errors = $('#reg-phones').find('.has-error').length
  successes = $('#reg-phones').find('.has-success').length
  labelParent = $('label[for=reg-phones]').parent()
  if errors is 0 and successes > 0
    labelParent.removeClass('has-error').addClass('has-feedback has-success')
  else
    if successes is 0 and errors > 0
      labelParent.removeClass('has-success').addClass('has-feedback has-error')
    else
      labelParent.removeClass('has-success has-error')
  return

initPhone = ($this) ->
  unless $this.attr('data-fv-field')
    form = $this.closest('form')
    console.log form
    form.formValidation('addField', $this, {
      err: $this.parent().parent()
      row:
        selector: '.field'
      validators:
        remote:
          type: 'POST'
          delay: 500
          message: "Такой телефон уже зарегистрирован на нашем сайте. <br/><a href='" + Routes.new_user_session_path() + "'>Выполните вход</a>."
          url: Routes.api_validation_index_path()
        phone:
          country: 'RU'
          message: "Такой телефон не допустим"
        notEmpty:
          message: "Пожалуйста, введите телефон"
      onError: (e, data) ->
        console.log $(e.target).closest('.fields')
        $(e.target).closest('.fields').removeClass('has-success').addClass('has-feedback has-error')
        colorLabel()

      onSuccess: (e, data) ->
        console.log $(e.target).closest('.fields')
        $(e.target).closest('.fields').removeClass('has-error').addClass('has-feedback has-success')
        colorLabel()
    })
    form.formValidation('revalidateField', $this.name)


$('form.easyBootstrapValidator:visible').livequery ->
  $this = $(this)
  $this.formValidation
    locale: 'ru_RU'
    framework: 'bootstrap'
    excluded: ':disabled'
    err:
      container: null
    row:
      selector: '.form-group'
    icon:
      valid: 'fa fa-check',
      invalid: 'fa fa-times',
      validating: 'fa fa-refresh'
  .on('err.field.fv', (e, data) ->
    if data.fv
      data.fv.disableSubmitButtons false
    return true
  ).on 'success.field.fv', (e, data) ->
    if data.fv
      data.fv.disableSubmitButtons false
    return true


#markLocation = (type, message)->
#  console.log $("label[for='#{type}']")
#  if message
#    $("label[for='#{type}']").addClass('control-label')
#  else
#    $("label[for='#{type}']").removeClass('control-label')

#err:
#  container: ($field, validator) ->
#    console.log("dsdsd" + validator)
#    getChildren.call()
#    return $('.validation-error-messages')

scrollToField = (destination) ->
  console.log('we are in scroll func')
  res = $('html')
  if ($.browser.safari)
    res = $('body')
  res.animate({scrollTop: destination }, 1100)
  return false

show_error_message = (parent, field, msg) ->
  getChildren.call(parent, null)
  $("validation-error-message-" + field).text(msg)
  console.log('we added message ' + msg + ' key ' + field)
  return


baseLocationValidation = (validator) ->
  location_el = $("div:not(.SelectLocation)[lid='0']")
  region_el = $("div:not(.SelectLocation)[lid][name='region']")
  regions = region_el.length
  cities = $("div:not(.SelectLocation)[lid][name='city']").length
#  city = $("div:not(.SelectLocation)[lid][name='city']").first()
  non_admin_areas = $("div:not(.SelectLocation)[lid][name='non_admin_area']").length
  rostov_el = $("div:not(.SelectLocation)[lid][name='city']:contains(г Ростов-на-Дону)")
  rostov = rostov_el.length
  rostovNonAdminArea = rostov_el.closest('.form-group-location').find("div:not(.SelectLocation)[lid][name='non_admin_area']").length
  rostovStreet = rostov_el.closest('.form-group-location').find("div:not(.SelectLocation)[lid][name='street']").length
#  container =  ($field, validator)->
#    getChildren.call(region_el)
#    return $("(.SelectLocation)[lid][name='city']").first

  if cities < 1
    message = 'Пожалуйста, укажите город'
    if validator
      scrollToField($('.GetChildren'))
#      parent = region_el if region_el
#      parent = location_el if !parent
#      show_error_message(parent,'city',message)
      return {
      valid: false
      message: message
      container: '.validation-locations'
      }
    else
      if regions is 1
        getChildren.call(region_el, null, ->
#          markLocation('city', message)
#          markLocation('district', message)
        )
      else
        if regions is 0
          getChildren.call(location_el, null, ->
#            markLocation('region', message)
          )
    return
  if rostov is 1 and rostovNonAdminArea is 0
    message = 'Пожалуйста, укажите неадминистративный район в г Ростов-на-Дону'
    if validator
      scrollToField($('.GetChildren'))
      return {
      valid: false
      message: message
      }
    else
      getChildren.call(rostov_el)
      return

  if rostov is 1 and rostovStreet is 0
    message = 'Пожалуйста, укажите улицу в г Ростов-на-Дону'
    if validator
      scrollToField($('.GetChildren'))
      return {
      valid: false
      message: message
      }
    else
      getChildren.call(rostov_el)
      return
  if validator
    return true
  else
    return

FormValidation.Validator.location_ids =  validate: (validator, $field, options) ->
  return baseLocationValidation(true)



$('form:not(".withoutBootstrapValidator"):not(".easyBootstrapValidator"):visible').livequery ->
  $this = $(this)
  $this.formValidation({
    locale: 'ru_RU'
    framework: 'bootstrap'
    excluded: ':disabled'
    err:
       container: null
    row:
      selector: '.form-group'
    icon:
      valid: 'fa fa-check',
      invalid: 'fa fa-times',
      validating: 'fa fa-refresh'
    fields:

      'advertisement[offer_type]':
        message: "Пожалуйста, выберите вид сделки"
        validators:
          callback:
            trigger: 'change'
            callback:  ->
              $('[name="advertisement[offer_type]"]').is(':checked')

      'advertisement[category]':
        message: "Пожалуйста, выберите тип недвижимости"
        validators:
          callback:
            trigger: 'change'
            callback:  ->
              $('[name="advertisement[category]"]').is(':checked')
      'location_validation':
        icon: false
#        err:
#          container: '.validation-locations'
        validators:
          location_ids:
            message: ''


  })
  .on('submit', (e, data) ->
    baseLocationValidation(false)
    $('#reg-phones input[type=text]:not(.checkPhone)').each ->
      $(this).focusout()
    $('input[type=text][name="user[email]"], input[type=text][name="advertisement[user_attributes][email]"]').each ->
      $(this).focusout()
    return true

  )
  .on('err.field.fv', (e, data) ->
    if data.field == 'location_validation'
      #if data.message == 'Пожалуйста, укажите город'
      key = ''
      if $('.help-block[data-fv-validator*="location_ids"]').text() == 'Пожалуйста, укажите город'
        key = 'region'
      if $('.help-block[data-fv-validator*="location_ids"]').text() == 'Пожалуйста, укажите неадминистративный район в г Ростов-на-Дону'
        key = 'city'
      msg = $('.help-block[data-fv-validator*="location_ids"]').text()
      $('.GetChildren').popover("destroy")
      getChildren.call($("div:not(.SelectLocation)[lid][name=#{key}]"), null, ->
        console.log('get child in city')
        $('.validation-locations').text(msg)
      )
      $('.validation-locations').text(msg)
#      if $('.help-block[data-fv-validator*="location_ids"]').text() == 'Пожалуйста, укажите город'
#        getChildren.call($("div:not(.SelectLocation)[lid][name='region']"), null)
#        console.log('get child in city')
#        $('.validation-locations').text('Пожалуйста, укажите город')
#      else if $('.help-block[data-fv-validator*="location_ids"]').text() == 'Пожалуйста, укажите неадминистративный район в г Ростов-на-Дону'
#        getChildren.call($("div:not(.SelectLocation)[lid][name='city']"), null)
#        console.log('get child in region')
#        $('.validation-locations').text('Пожалуйста, укажите неадминистративный район в г Ростов-на-Дону')
#      else if $('.help-block[data-fv-validator*="location_ids"]').text() == 'Пожалуйста, укажите улицу в г Ростов-на-Дону'
#        getChildren.call($("div:not(.SelectLocation)[lid][name='city']"), null)
#        console.log('get in child district in rostov')
#        $('.validation-locations').text('Пожалуйста, укажите улицу в г Ростов-на-Дону')

    if data.fv
      data.fv.disableSubmitButtons false
    return true
  ).on('success.field.fv', (e, data) ->
    if data.fv
      data.fv.disableSubmitButtons false
    return true
  )
  .on 'focusout', 'input', ->
    $this.formValidation('validateField', $(this).attr('name'))
    return true


$('input[type=text][name="user[email]"], input[type=text][name="advertisement[user_attributes][email]"]').livequery ->
  $this = $(this)
  $this.focusout ->
    initEmail($this)



$('#reg-phones input[type=text]:not(.checkPhone)').livequery ->
  $this = $(this)
  $this.focusout ->
    initPhone($this)

$('form .attributes input, form .attributes textarea').livequery ->
  $this = $(this)
  unless $this.attr('data-bv-field')
    form = $(this).closest('form')
    form.bootstrapValidator('addField', $(this))



$('input[type="text"][valid-type=integer]').livequery ->
  $(this).forceNumericOnly()


$('input[type="text"][valid-type=float]').livequery ->
  $(this).forceFloatOnly()