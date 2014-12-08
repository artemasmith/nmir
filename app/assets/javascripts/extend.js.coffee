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


$.extend $.expr[":"],
  icontains: (elem, i, match, array) ->
    (elem.textContent or elem.innerText or "").toLowerCase().indexOf((match[3] or "").toLowerCase()) >= 0

$.rails.allowAction = (link) ->
  return true unless link.attr('data-confirm')
  $.rails.showConfirmDialog(link) # look bellow for implementations
  false # always stops the action since code runs asynchronously

$.rails.confirmed = (link) ->
  link.removeAttr('data-confirm')
  link.trigger('click.rails')

$.rails.showConfirmDialog = (link) ->
  message = link.attr 'data-confirm'
  html =
#         """
#         <div class="modal" id="confirmationDialog">
#           <div class="modal-header">
#             <a class="close" data-dismiss="modal">×</a>
#             <h3>#{message}</h3>
#           </div>
#           <div class="modal-body">
#             <p>Are you sure you want to delete?</p>
#           </div>
#           <div class="modal-footer">
#             <a data-dismiss="modal" class="btn">Cancel</a>
#             <a data-dismiss="modal" class="btn btn-primary confirm">OK</a>
#           </div>
#         </div>
#         """

         """
         <div class="modal" id="confirmationDialog">
           <div class="modal-dialog">
             <div class="modal-content">
               <div class="modal-header">
                 <button type="button" class="close" data-dismiss="modal"><span aria-hidden="true">&times;</span><span class="sr-only">Close</span></button>
                 <h4 class="modal-title">Требуется подтверждение</h4>
               </div>
               <div class="modal-body">
                 <p>#{message}</p>
               </div>
               <div class="modal-footer">
                 <a data-dismiss="modal" class="btn">Нет</a>
                 <a data-dismiss="modal" class="btn btn-primary confirm">Да</a>
               </div>
             </div>
           </div>
         </div>
         """
  $(html).modal()
  $('#confirmationDialog .confirm').on 'click', -> $.rails.confirmed(link)







