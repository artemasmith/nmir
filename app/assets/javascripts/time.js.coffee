define "time_utils", ["jquery", "check_helper_utils", "livequery"], ->

  monthNames =  ["января", "февраля", "марта", "апреля", "мая", "июня", "июля", "августа", "сентября", "октября", "ноябрь", "декабря"]

  date_offset = (el)->
    d = new Date(el.attr('datetime'))
    currentDate = new Date()
    timeZone = parseInt el.attr('time_zone')
    offset = (timeZone - (currentDate.getTimezoneOffset() / 60 * -1)) * 60 * 60 * 1000
    d.setTime(d.getTime() + offset)
    return d

  currentTime = ()->
    new Date().getTime()

  startTime = (el)->
    return date_offset(el).getTime()

  timeToStr = (el)->
    st = date_offset(el)
    hours = st.getHours()
    minutes = st.getMinutes()
    if hours < 10
      hoursStr = '0' + hours
    else
      hoursStr =  hours

    if minutes < 10
      minutesStr = '0' + minutes
    else
      minutesStr =  minutes
    return "#{hoursStr}:#{minutesStr}"

  dateToStr = (el)->
    st = date_offset(el)
    date = st.getDate()
    month = st.getMonth()

    monthStr = monthNames[month]
    return "#{date} #{monthStr}"

  isToday = (el)->
    date = date_offset(el)
    current_date = new Date()
    return (date.getYear() is current_date.getYear()) and (date.getMonth() is current_date.getMonth()) and (date.getDate() is current_date.getDate())

  isYesterday = (el)->
    date = date_offset(el)
    current_date = new Date(new Date().setDate(new Date().getDate()-1))
    return (date.getYear() is current_date.getYear()) and (date.getMonth() is current_date.getMonth()) and (date.getDate() is current_date.getDate())


  setTime = (el)->
    distance = ((currentTime() - startTime(el)) / 1000)
    text = switch
      when distance < 60 then "только что"
      when distance < 120 then "минуту назад"
      when distance <= 60*59 then Math.round(distance / 60) + " " + CheckHelper.declOfNum(Math.round(distance / 60), ["минуту назад", "минуты назад", "минут назад"])
      when isToday(el) then "сегодня в #{timeToStr(el)}"
      when isYesterday(el) then "вчера в #{timeToStr(el)}"
      else
        dateToStr(el)

    el.text(text)
    return

  $('time.smart_time[datetime]').livequery ->
    $this = $(this)
    setTime($this)
    setInterval(
      ->
        setTime($this)
      , 1000
    )





