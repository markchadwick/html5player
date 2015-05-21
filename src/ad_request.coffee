inject = require 'honk-di'
Logger = require './logger'
{Ajax} = require 'ajax'


class AdRequest

  config:     inject 'config'
  http:       inject Ajax
  log:        inject Logger
  navigator:  inject 'navigator'

  fetch: ->
    body = JSON.stringify(@body())
    @log.write name: 'AdRequest', message: "#{@config.url} POST #{body}"
    @http.request
      type:             'POST'
      url:              @config.url
      dataType:         'json'
      data:             body
      withCredentials:  false

  body: ->
    # number_of_screens is deprecated
    api_key:            @config.apiKey
    device_attribute:   @_deviceAttribute()
    device_id:          @config.deviceId
    direct_connection:  @config.directConnection
    display_area:       @_displayArea()
    display_time:       @_displayTime()
    latitude:           @config.latitude
    longitude:          @config.longitude
    network_id:         @config.networkId
    venue_id:           @config.venueId
    number_of_screens:  1

  supportedMedia: ->
    # assume that all browsers can at least deal with these
    media  = ['image/gif', 'image/jpeg', 'image/png', 'video/webm']
    if @config.mimeTypes?.length > 0
      @config.mimeTypes
    else
      for m in @navigator.mimeTypes
        media.push(m.type)
      media

  _displayArea: ->
    if not @config.displayArea
      throw new Error('must configure a displayArea list')
    for screen in @config.displayArea
      screen.supported_media = @supportedMedia()
      screen

  _deviceAttribute: -> [
    {
      name: 'UserAgent'
      value: @navigator.userAgent
    }
    {
      name: 'MimeTypes'
      value: @supportedMedia().join(', ')
    }

  ]

  # In the rare case that a single campaign is pacing at the same frequency it's
  # being played (1 spot per 30s, for example), the last screen that played the
  # ad will request at exactly the right time to get the next available
  # impression.
  _displayTime: ->
    nowSec = new Date().getTime() / 1000
    futureSec = Math.random() * 60

    Math.round(nowSec + futureSec)


module.exports = AdRequest
