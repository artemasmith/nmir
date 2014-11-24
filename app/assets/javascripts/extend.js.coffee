unless window.console
  window.console = {}

# union of Chrome, FF, IE, and Safari console methods
m = [
  "log"
  "info"
  "warn"
  "error"
  "debug"
  "trace"
  "dir"
  "group"
  "groupCollapsed"
  "groupEnd"
  "time"
  "timeEnd"
  "profile"
  "profileEnd"
  "dirxml"
  "assert"
  "count"
  "markTimeline"
  "timeStamp"
  "clear"
]

# define undefined methods as noops to prevent errors
i = 0
while i < m.length
  unless window.console[m[i]]
    window.console[m[i]] = ->
  i++

window.onDemandScript = (url, saveHistory = true) ->
  u = new Url url;
  u.query['save_history'] = saveHistory unless saveHistory
  new_url = u.toString()
  $.getScript new_url, ()->
    return
  return

$.fn.hasScrollBar = ->
  this.get(0).scrollHeight > this.height()

$.browser = {}
$.browser.mozilla = /mozilla/.test(navigator.userAgent.toLowerCase()) and not /webkit/.test(navigator.userAgent.toLowerCase())
$.browser.webkit = /webkit/.test(navigator.userAgent.toLowerCase())
$.browser.opera = /opera/.test(navigator.userAgent.toLowerCase())
$.browser.msie = /msie/.test(navigator.userAgent.toLowerCase())


oldReplaceWith = $.fn.replaceWith
jQuery.fn.replaceWith = (value) ->
  if $.trim(value) is ''
    @each ->
      $(this).remove()
    return
  else
    return oldReplaceWith.apply this, arguments

$.fn.forceFloatOnly = ->
  expression = /^(\d+(\.\d{0,2})?)?$/
  @each ->
    oldValue = $(this).val()
    $(this).keydown (e) ->
      key = e.charCode or e.keyCode or 0
      (key is 110 or key is 8 or key is 9 or key is 13 or key is 46 or key is 110 or key is 190 or (key >= 35 and key <= 40) or (key >= 48 and key <= 57) or (key >= 96 and key <= 105)) and (!e.shiftKey)
    $(this).keydown () ->
      value = $(this).val()
      if expression.test(value)
        oldValue = value
    $(this).on 'keypress keyup', () ->
      value = $(this).val()
      unless expression.test(value)
        $(this).val(oldValue)
        return false
      return true

$.fn.forceNumericOnly = ->
  expression = /^(\d+)?$/
  @each ->
    oldValue = $(this).val()
    $(this).keydown (e) ->
      key = e.charCode or e.keyCode or 0
      # allow backspace, tab, delete, enter, arrows, numbers and keypad numbers ONLY
      # home, end, period, and numpad decimal
      (key is 8 or key is 9 or key is 13 or key is 46 or key is 110 or key is 190 or (key >= 35 and key <= 40) or (key >= 48 and key <= 57) or (key >= 96 and key <= 105)) and (!e.shiftKey)
    $(this).keydown () ->
      value = $(this).val()
      if expression.test(value)
        oldValue = value
    $(this).on 'keypress keyup', () ->
      value = $(this).val()
      unless expression.test(value)
        $(this).val(oldValue)
        return false
      return true







