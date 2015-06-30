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

$('input[type=text][name="user[email]"], input[type=text][name="advertisement[user_attributes][email]"]').livequery ->
  $this = $(this)
  $this.focusout ->
    initEmail($this)

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
          message: "Пожалуйста, введите телефон с кодом города/сети"
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


initPassword = ($this) ->
  console.log('inipass')
#  unless $this.attr('data-fv-field')
  console.log('in unless cile')
  form = $this.closest('form')
  console.log form
  validators =
    password:
      message: "Пожалуйста, введите password"
    notEmpty:
      message: "Пожалуйста, введите password"
    stringLength:
      message: 'Min length is 6 symbols'
      min: 6

  form.formValidation('addField', $this, {
    validators: validators
  })
  form.formValidation('revalidateField', $this.name)


$('input[type=password][name="user[password]"], input[type=password][name="advertisement[user_attributes][password]"]').livequery ->
  $this = $(this)
  $this.focusout ->
    initPassword($this)


$('#reg-phones input[type=text]:not(.checkPhone)').livequery ->
  $this = $(this)
  $this.focusout ->
    initPhone($this)

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
  res = $('html')
  if ($.browser.safari)
    res = $('body')
  res.animate({scrollTop: destination }, 1100)
  return false

show_error_msg = (dom, msg) ->
  $(dom).text(msg)
  return

baseLocationValidation = (validator) ->
  location_el = $("div:not(.SelectLocation)[lid='0']")
  region_el = $("div:not(.SelectLocation)[lid][name='region']")
  regions = region_el.length
  cities = $("div:not(.SelectLocation)[lid][name='city']").length
#  city = $("div:not(.SelectLocation)[lid][name='city']").first()
  rostov_el = $("div:not(.SelectLocation)[lid][name='city']:contains(г Ростов-на-Дону)")
  rostov = rostov_el.length
  rostovNonAdminArea = rostov_el.closest('.form-group-location').find("div:not(.SelectLocation)[lid][name='non_admin_area']").length
  rostovStreet = rostov_el.closest('.form-group-location').find("div:not(.SelectLocation)[lid][name='street']").length

  if cities < 1
    message = 'Пожалуйста, укажите город'
    if validator
      return {
      valid: false
      message: message
      }
    else
      if regions is 1
        getChildren.call(region_el, null, ->
#          console.log('region is 1')
          show_error_msg('.validation-error-message.city', message)

#          markLocation('city', message)
#          markLocation('district', message)
        )
      else
        if regions is 0
#          console.log('region is 0')
          getChildren.call(location_el, null, ->
#            markLocation('region', message)
          )
    return
  if rostov is 1 and rostovNonAdminArea is 0
    message = 'Пожалуйста, укажите неадминистративный район в г Ростов-на-Дону'
    if validator
      return {
      valid: false
      message: message
      }
    else
#      console.log('rostov 1 and rostovnonadmin else')
      getChildren.call(rostov_el, null,->
        show_error_msg('.validation-error-message.non_admin_area', message))
      return

  if rostov is 1 and rostovStreet is 0
    message = 'Пожалуйста, укажите улицу в г Ростов-на-Дону'
    if validator
      return {
      valid: false
      message: message
      }
    else
#      console.log('rostov is 1 and rostov street 0 else')
      getChildren.call(rostov_el, null, ->
        show_error_msg('.validation-error-message.street', message))
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
      scrollToField($('.GetChildren'))
      error_msg = $('.help-block[data-fv-validator*="location_ids"]').text()
      isvalid = true
      $('form').data('formValidation').$invalidFields.each((i) ->
        isvalid = false if $(this)[i].name == 'location_validation')
      key = ''
      validation_location_type = ''
      if error_msg == 'Пожалуйста, укажите город' && !isvalid
        key = 'region'
        validation_location_type = 'city'
      if error_msg == 'Пожалуйста, укажите неадминистративный район в г Ростов-на-Дону' && !isvalid
        key = 'city'
        validation_location_type = 'non_admin_area'
      if error_msg == 'Пожалуйста, укажите улицу в г Ростов-на-Дону' && !isvalid
        key = 'city'
        validation_location_type = 'street'
      el = $('.GetChildren')
      el.popover("destroy")
      $('.GetChildren').removeClass('active')
      $('.GetChildren').removeClass('dropdown-toggle')
#      console.log('message ' + error_msg)
#      console.log('before get children in validation ' + isvalid + 'key '+ $("div:not(.SelectLocation)[lid][name=#{key}]"))
      getChildren.call($("div:not(.SelectLocation)[lid][name=#{key}]"), null, ->
#        console.log('get child in city ' + key)
        $('.validation-error-message.' + validation_location_type).text(error_msg)
#        $('.validation-locations').text(error_msg)
      )

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



$('form .attributes input, form .attributes textarea').livequery ->
  $this = $(this)
  unless $this.attr('data-bv-field')
    form = $(this).closest('form')
    form.bootstrapValidator('addField', $(this))



$('input[type="text"][valid-type=integer]').livequery ->
  $(this).forceNumericOnly()


$('input[type="text"][valid-type=float]').livequery ->
  $(this).forceFloatOnly()