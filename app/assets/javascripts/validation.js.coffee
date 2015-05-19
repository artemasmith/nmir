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
    message = 'Укажите город'
    if validator
      return {
      valid: false
      message: message
      }
    else
      if regions is 1
        getChildren.call(region_el)
      else
        if regions is 0
          getChildren.call(location_el)
    return
  if rostov is 1 and rostovNonAdminArea is 0
    message = 'Укажите неадминистративный район в г Ростов-на-Дону'
    if validator
      return {
      valid: false
      message: message
      }
    else
      getChildren.call(rostov_el)
      return

  if rostov is 1 and rostovStreet is 0
    message = 'Укажите улицу в г Ростов-на-Дону'
    if validator
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

FormValidation.Validator.location_ids = validate: (validator, $field, options) ->
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
      'user[email]':
        validators:
          remote:
            type: 'POST'
            url: Routes.api_validation_index_path()
            message: "Такой email уже зарегистрирован на нашем сайте. <br/><a href='" + Routes.new_user_session_path() + "'>Выполните вход</a>."


      'advertisement[user_attributes][email]':
        validators:
          remote:
            type: 'POST'
            url: Routes.api_validation_index_path()
            message: "Такой email уже зарегистрирован на нашем сайте. <br/><a href='" + Routes.new_user_session_path() + "'>Выполните вход</a>."


      'advertisement[offer_type]':
        message: "Выберите вид сделки"
        validators:
          callback:
            trigger: 'change'
            callback:  ->
              $('[name="advertisement[offer_type]"]').is(':checked')

      'advertisement[category]':
        message: "Выберите тип недвижимости"
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


  })
  .on('submit', (e, data) ->
    baseLocationValidation(false)
    return true
  ).on('err.field.fv', (e, data) ->
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




$('#reg-phones input[type=text]:not(.checkPhone)').livequery ->
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

  $this = $(this)
  $this.closest('form').formValidation('addField', $this, {
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
        message: "Необходимо ввести телефон"
    onError: (e, data) ->
      console.log $(e.target).closest('.fields')
      $(e.target).closest('.fields').removeClass('has-success').addClass('has-feedback has-error')
      colorLabel()


    onSuccess: (e, data) ->
      console.log $(e.target).closest('.fields')
      $(e.target).closest('.fields').removeClass('has-error').addClass('has-feedback has-success')
      colorLabel()
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