# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/
#
#= require fullcalendar
#= require jquery.boxy
#= require sprintf
#= require scheduler

SocialStream.Events.tools = {}

SocialStream.Events.tools.currentRGB = () ->
  [ parseInt(SocialStream.Events.current.eventColor[1..2], 16),
  parseInt(SocialStream.Events.current.eventColor[3..4], 16),
  parseInt(SocialStream.Events.current.eventColor[5..6], 16) ]

SocialStream.Events.tools.colorRange = () ->
  min = 0

  for color in SocialStream.Events.tools.currentRGB()
    if color < min
      min = color
  
  parseInt 2 * (255 - min) / 3

SocialStream.Events.tools.increaseColor = (delta) ->
   (if (color + delta) > 255 then 255 else (color + delta)) for color in SocialStream.Events.tools.currentRGB()
  

SocialStream.Events.tools.eventColorScale = (index) ->
  range = SocialStream.Events.tools.colorRange()

  delta = range * (index + 1) / (SocialStream.Events.current.roomIndex.length + 1)

  delta = parseInt(delta)

  newColor = SocialStream.Events.tools.increaseColor(delta)

  sprintf "#%02x%02x%02x", newColor[0], newColor[1], newColor[2]
  

SocialStream.Events.tools.eventColor = (roomId) ->
  currentColor = SocialStream.Events.current.eventColor

  if not roomId? or not SocialStream.Events.current.roomIndex? or SocialStream.Events.current.roomIndex.length == 0
    return currentColor

  currentRoomIndex = SocialStream.Events.current.roomIndex.indexOf(roomId)

  SocialStream.Events.tools.eventColorScale(currentRoomIndex)
