$('form.easyBootstrapValidator:visible').livequery ->
  $(this).formValidation
    locale: 'ru_RU'
    framework: 'bootstrap'
    err: container: 'tooltip'
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
#    row: selector: 'td'
#    button: selector: '#submitButton'
#  $(this).bootstrapValidator({
#    feedbackIcons:
#      valid: 'fa fa-check',
#      invalid: 'fa fa-times',
#      validating: 'fa fa-refresh'
#  })


FormValidation.Validator.location_ids = validate: (validator, $field, options) ->
  regions = $("div:not(.SelectLocation)[lid][name='region']").length
  cities = $("div:not(.SelectLocation)[lid][name='city']").length
  non_admin_areas = $("div:not(.SelectLocation)[lid][name='non_admin_area']").length
  console.log 'FIRE!!!'
  if cities < 1
    return {
    valid: false
    message: 'Укажите город'
    }
  true


#example - delete after refactoring for delete
$('.example-form').livequery ->
  $(this).formValidation({
    locale: 'ru_RU'
    framework: 'bootstrap'
    #err: container: 'popover'
    excluded: ':disabled'
    icon:
      valid: 'fa fa-check',
      invalid: 'fa fa-times',
      validating: 'fa fa-refresh'
    fields:
      'advertisement[location_ids][]':
        validators:
          location_ids:
            message: 'dfdf'

  })

$('form:not(".withoutBootstrapValidator"):not(".easyBootstrapValidator"):visible').livequery ->
  $(this).formValidation({
    locale: 'ru_RU'
    framework: 'bootstrap'
    excluded: ':disabled'
    err: container: 'popover'
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
        icon: false
        validators:
          callback:
            trigger: 'change'
            callback:  ->
              $('[name="advertisement[offer_type]"]').is(':checked')

      'advertisement[category]':
        message: "Выберите тип недвижимости"
        icon: false
        validators:
          callback:
            trigger: 'change'
            callback:  ->
              $('[name="advertisement[category]"]').is(':checked')
      'advertisement[location_ids][]':
        excluded: false
        validators:
          location_ids:
            message: 'Please fill out each field'

          notEmpty:
            message: 'Please fill out each field'
      'location_validation':
        validators:
          location_ids:
            message: 'sad'


  })

$('#new_advertisement').formValidation('revalidateField', 'advertisement[location_ids][]');
$('#reg-phones input[type=text]:not(.checkPhone)').livequery ->
  $this = $(this)
  console.log $this.closest('form')
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
    $(this).closest('form').bootstrapValidator('addField', $(this))


$('input[type="text"][valid-type=integer]').livequery ->
  $(this).forceNumericOnly()


$('input[type="text"][valid-type=float]').livequery ->
  $(this).forceFloatOnly()