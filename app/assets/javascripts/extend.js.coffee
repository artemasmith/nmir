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







