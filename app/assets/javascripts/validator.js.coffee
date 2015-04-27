$('form.easyBootstrapValidator:visible').livequery ->
  $(this).bootstrapValidator({
    feedbackIcons:
      valid: 'glyphicon glyphicon-ok'
      invalid: 'glyphicon glyphicon-remove'
      validating: 'glyphicon glyphicon-refresh'
  })

##

$('.find-location-form').livequery ->
  $(this).bootstrapValidator({
    feedbackIcons:
      valid: 'glyphicon glyphicon-ok'
      invalid: 'glyphicon glyphicon-remove'
      validating: 'glyphicon glyphicon-refresh'
    #VERY IMPORTANT!!
    excluded: ':disabled'
    submitHandler: ->
      $("button[type='submit']").removeAttr('disabled');
      return false;
    fields:
      'advertisement[location_ids][]':
        validators:
          notEmpty:
            message: 'Выберите местоположение где искать'
          remote:
            message: 'Поиск только по области невозможен'
            url: Routes.check_if_specific_api_validation_index_path()
  })
  .on('err.field.fv', (e, data) ->
    console.log("data " + data)
    data.fv.disableSubmitButtons(false)
  )
  .on('success.field.fv', (e, data) ->
    data.fv.disableSubmitButtons(false)
  )



$('form:not(".withoutBootstrapValidator"):not(".easyBootstrapValidator"):visible').livequery ->
  $(this).bootstrapValidator({
    feedbackIcons:
      valid: 'glyphicon glyphicon-ok'
      invalid: 'glyphicon glyphicon-remove'
      validating: 'glyphicon glyphicon-refresh'
    fields:
      'advertisement[user_attributes][password]':
        validators:
          stringLength:
            min: 4
            message: "Пароль должен быть не меньще 4 символов"
      'advertisement[user_attributes][password_confirmation]':
        validators:
          stringLength:
            min: 4
            message: "Пароль должен быть не меньще 4 символов"
      'user[email]':
        message: "Такой email не допустим"
        validators:
          remote:
            message: ("Такой email уже зарегистрирован на нашем сайте. Используйте другой или <a href='" + Routes.new_user_session_path() + "'>выполните вход</a>.")
            url: Routes.api_validation_index_path()
      'advertisement[user_attributes][email]':
        message: "Такой email не допустим"
        validators:
          remote:
            message: ("Такой email уже зарегистрирован на нашем сайте. Используйте другой или <a href='" + Routes.new_user_session_path() + "'>выполните вход</a>.")
            url: Routes.api_validation_index_path()
      'advertisement[offer_type]':
        validators:
          callback:
            message: "Выберите вид сделки"
            trigger: 'change'
            callback:  ->
              $('[name="advertisement[offer_type]"]').is(':checked')

      'advertisement[category]':
        validators:
          callback:
            message: "Выберите тип недвижимости"
            trigger: 'change'
            callback:  ->
              $('[name="advertisement[category]"]').is(':checked')


  })

##

$('form .attributes input, form .attributes textarea').livequery ->
  $this = $(this)
  unless $this.attr('data-bv-field')
    $(this).closest('form').bootstrapValidator('addField', $(this))

##

$('#reg-phones input[type=text]:not(.checkPhone)').livequery ->
  $this = $(this)
  console.log $this.closest('form')
  $this.closest('form').bootstrapValidator('addField', $this, {
    message: "Такой телефон не допустим"
    validators:
      remote:
        message: ("Такой телефон уже зарегистрирован на нашем сайте. Используйте другой телефон.")
        url: Routes.api_validation_index_path()
  })

##

$('input[type="text"][valid-type=integer]').livequery ->
  $(this).forceNumericOnly()

##

$('input[type="text"][valid-type=float]').livequery ->
  $(this).forceFloatOnly()
