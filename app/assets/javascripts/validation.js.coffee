$('form.easyBootstrapValidator:visible').livequery ->
  $this = $(this)
  $this.formValidation
    locale: 'ru_RU'
    framework: 'bootstrap'
    err:
      container: 'popover'
    icon:
      valid: 'fa fa-check',
      invalid: 'fa fa-times',
      validating: 'fa fa-refresh'
    fields:
      'user[password_confirmation]':
        message: "Пароли не совпадают"
        validators:
          callback:
            trigger: 'blur'
            callback:  (value, validator, $field) ->
              value is $('[name="user[password]"]').val()
  .on('err.field.fv', (e, data) ->
    if data.fv
      data.fv.disableSubmitButtons false
    return
  ).on 'success.field.fv', (e, data) ->
    if data.fv
      data.fv.disableSubmitButtons false
    return

baseLocationValidation = (validator)->
  location_el = $("div:not(.SelectLocation)[lid='0']")
  region_el = $("div:not(.SelectLocation)[lid][name='region']")
  regions = region_el.length
  cities = $("div:not(.SelectLocation)[lid][name='city']").length
  non_admin_areas = $("div:not(.SelectLocation)[lid][name='non_admin_area']").length
  rostov_el = $("div:not(.SelectLocation)[lid][name='city']:contains(г Ростов-на-Дону)")
  rostov = rostov_el.length
  rostovNonAdminArea = rostov_el.closest('.form-group-location').find("div:not(.SelectLocation)[lid][name='non_admin_area']").length
  rostovStreet = rostov_el.closest('.form-group-location').find("div:not(.SelectLocation)[lid][name='street']").length
  if cities < 1
    if validator
      return {
      valid: false
      message: 'Укажите город'
      }
    else
      if regions is 1
        getChildren.call(region_el)
      else
        if regions is 0
          getChildren.call(location_el)
    return
  if rostov is 1 and rostovNonAdminArea is 0
    if validator
      return {
      valid: false
      message: 'Укажите неадминистративный район в г Ростов-на-Дону'
      }
    else
      getChildren.call(rostov_el)
      return

  if rostov is 1 and rostovStreet is 0
    if validator
      return {
      valid: false
      message: 'Укажите улицу в г Ростов-на-Дону'
      }
    else
      getChildren.call(rostov_el)
      return
  if validator
    return true
  else
    return

FormValidation.Validator.location_ids = validate: (validator, $field, options) ->
  return baseLocationValidation(true)



$('form:not(".withoutBootstrapValidator"):not(".easyBootstrapValidator"):visible').livequery ->
  $this = $(this)
  $this.formValidation({
    locale: 'ru_RU'
    framework: 'bootstrap'
    excluded: ':disabled'
    err:
      container: 'popover'
    icon:
      valid: 'fa fa-check',
      invalid: 'fa fa-times',
      validating: 'fa fa-refresh'
    fields:
      'advertisement[user_attributes][password]':
        validators:
          message: "Пароль должен быть не меньше 4 символов"
          stringLength:
            min: 4
      'advertisement[user_attributes][password_confirmation]':
        trigger: 'blur'
        validators:
          message: "Пароль должен быть не меньше 4 символов"
          stringLength:
            min: 4
      'advertisement[user_attributes][password_confirmation]':
        message: "Пароли не совпадают"
        validators:
          callback:
            trigger: 'blur'
            callback:  (value, validator, $field) ->
              value is $('[name="advertisement[user_attributes][password]"]').val()

      'user[password]':
        validators:
          message: "Пароль должен быть не меньше 4 символов"
          stringLength:
            min: 4
      'user[password_confirmation]':
        trigger: 'blur'
        validators:
          message: "Пароль должен быть не меньше 4 символов"
          stringLength:
            min: 4
      'user[password_confirmation]':
        message: "Пароли не совпадают"
        validators:
          callback:
            trigger: 'blur'
            callback:  (value, validator, $field) ->
              value is $('[name="user[password]"]').val()

      'user[email]':
        validators:
          remote:
            type: 'POST'
            delay: 500
            url: Routes.api_validation_index_path()
            message: "Такой email уже зарегистрирован на нашем сайте. Используйте другой или <a href='" + Routes.new_user_session_path() + "'>выполните вход</a>."


      'advertisement[user_attributes][email]':
        validators:
          remote:
            type: 'POST'
            delay: 500
            url: Routes.api_validation_index_path()
            message: "Такой email уже зарегистрирован на нашем сайте. Используйте другой или <a href='" + Routes.new_user_session_path() + "'>выполните вход</a>."


      'advertisement[offer_type]':
        message: "Выберите вид сделки"
#        icon: false
        validators:
          callback:
            trigger: 'change'
            callback:  ->
              $('[name="advertisement[offer_type]"]').is(':checked')

      'advertisement[category]':
        message: "Выберите тип недвижимости"
#        icon: false
        validators:
          callback:
            trigger: 'change'
            callback:  ->
              $('[name="advertisement[category]"]').is(':checked')
      'location_validation':
        onError: (e, data) ->
        validators:
          location_ids:
            message: ''


  }).on('submit', (e, data) ->
    baseLocationValidation(false)
  ).on('err.field.fv', (e, data) ->
    if data.fv
      data.fv.disableSubmitButtons false
    return
  ).on('success.field.fv', (e, data) ->
    if data.fv
      data.fv.disableSubmitButtons false
    return
  )


#  .on 'focusout', '[name="user[email]"], [name="advertisement[user_attributes][email]"], [name="user[name]"], [name="advertisement[user_attributes][name]"], [name="advertisement[price_from]"]', ->
#    unless $this.find('[type="submit"]:visible').is(':focus')
#      $this.formValidation('validateField', $(this).attr('name'))
#    return




$('#reg-phones input[type=text]:not(.checkPhone)').livequery ->
  $this = $(this)
  $this.closest('form').formValidation('addField', $this, {
    validators:
      remote:
        type: 'POST'
        delay: 500
        trigger: 'keypress'
        message: "Такой телефон уже зарегистрирован на нашем сайте. Используйте другой телефон."
        url: Routes.api_validation_index_path()
      phone:
        country: 'RU'
        message: "Такой телефон не допустим"
      notEmpty:
        message: "Необходимо ввести телефон"
  })

$('form .attributes input, form .attributes textarea').livequery ->
  $this = $(this)
  unless $this.attr('data-bv-field')
    form = $(this).closest('form')
    form.bootstrapValidator('addField', $(this))



$('input[type="text"][valid-type=integer]').livequery ->
  $(this).forceNumericOnly()


$('input[type="text"][valid-type=float]').livequery ->
  $(this).forceFloatOnly()