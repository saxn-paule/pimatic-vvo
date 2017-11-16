module.exports = (env) ->

  Promise = env.require 'bluebird'
  assert = env.require 'cassert'
  M = env.matcher
  Request = require 'request'
  api = "https://webapi.vvo-online.de/dm?format=json";

  #mockJson = {"Name":"Merianplatz","Status":{"Code":"Ok"},"Place":"Dresden","ExpirationTime":"\/Date(1510265515463+0100)\/","Departures":[{"Id":"70729498","LineName":"7","Direction":"Pennrich","Platform":{"Name":"2","Type":"Platform"},"Mot":"Tram","RealTime":"\/Date(1510266000000+0100)\/","ScheduledTime":"\/Date(1510266000000+0100)\/","State":"InTime","RouteChanges":[],"Diva":{"Number":"11007","Network":"voe"}},{"Id":"70731143","LineName":"44","Direction":"Gorbitz","Platform":{"Name":"2","Type":"Platform"},"Mot":"Tram","RealTime":"\/Date(1510266010000+0100)\/","ScheduledTime":"\/Date(1510265940000+0100)\/","State":"Delayed","RouteChanges":["510972","511363"],"Diva":{"Number":"11044","Network":"voe"}},{"Id":"70728574","LineName":"2","Direction":"Kleinzschachwitz","Platform":{"Name":"1","Type":"Platform"},"Mot":"Tram","RealTime":"\/Date(1510266300000+0100)\/","ScheduledTime":"\/Date(1510266300000+0100)\/","State":"InTime","RouteChanges":["511363"],"Diva":{"Number":"11002","Network":"voe"}},{"Id":"70728464","LineName":"2","Direction":"Gorbitz","Platform":{"Name":"2","Type":"Platform"},"Mot":"Tram","RealTime":"\/Date(1510266660000+0100)\/","ScheduledTime":"\/Date(1510266660000+0100)\/","State":"InTime","RouteChanges":["511363"],"Diva":{"Number":"11002","Network":"voe"}},{"Id":"70729626","LineName":"7","Direction":"Weixdorf","Platform":{"Name":"1","Type":"Platform"},"Mot":"Tram","RealTime":"\/Date(1510267260000+0100)\/","ScheduledTime":"\/Date(1510267260000+0100)\/","State":"InTime","RouteChanges":[],"Diva":{"Number":"11007","Network":"voe"}},{"Id":"70730165","LineName":"10","Direction":"Gorbitz","Platform":{"Name":"2","Type":"Platform"},"Mot":"Tram","RealTime":"\/Date(1510267336000+0100)\/","ScheduledTime":"\/Date(1510267260000+0100)\/","State":"Delayed","RouteChanges":["510972","511363"],"Diva":{"Number":"11010","Network":"voe"}}]}
  mockhtml = '<div class="dvb"><div class="stop">Merianplatz</div><div class="clear"/>  <div class="head">  <div class="line caption col-1">Linie</div>			<div class="target caption col-2">Ziel</div>  <div class="minutes caption col-3">Min.</div>		</div>  <div class="clear"/>  <div class="col-1">2</div>		<div class="col-2">Kleinzschachwitz</div>  <div class="col-3">5</div>		<div class="clear"/>  <div class="col-1">7</div>		<div class="col-2">Pennrich</div>  <div class="col-3">9</div>		<div class="clear"/>  <div class="col-1">2</div>		<div class="col-2">Gorbitz</div>  <div class="col-3">13</div>		<div class="clear"/>  <div class="col-1">1</div>		<div class="col-2">Gorbitz</div>  <div class="col-3">14</div>		<div class="clear"/>  <div class="col-1">7</div>		<div class="col-2">Weixdorf</div>  <div class="col-3">21</div>		<div class="clear"/>  <div class="col-1">11</div>		<div class="col-2">Gorbitz</div>  <div class="col-3">22</div>		<div class="clear"/></div>'

  class VvoPlugin extends env.plugins.Plugin

    init: (app, @framework, @config) =>

      @framework.ruleManager.addActionProvider(new VvoActionProvider(@framework))

      deviceConfigDef = require("./device-config-schema")
      @framework.deviceManager.registerDeviceClass("VvoDevice",{
        configDef : deviceConfigDef.VvoDevice,
        createCallback : (config) => new VvoDevice(config,this)
      })

      @framework.on "after init", =>
        mobileFrontend = @framework.pluginManager.getPlugin 'mobile-frontend'
        if mobileFrontend?
          mobileFrontend.registerAssetFile 'js', "pimatic-vvo/app/vvoTempl-page.coffee"
          mobileFrontend.registerAssetFile 'html', "pimatic-vvo/app/vvoTempl-template.html"
          mobileFrontend.registerAssetFile 'css', "pimatic-vvo/app/css/vvo.css"

        return

  class VvoDevice extends env.devices.Device
    constructor: (@config, @plugin) ->
      @id = @config.id
      @name = @config.name
      @stopid = @config.stopid
      @amount = @config.amount or "5"
      @offset = @config.offset or "0"
      @schedule = mockhtml

      env.logger.info "StopId: " + @stopid

      setInterval ( =>
        @reLoadSchedule()
      ), 15000

      super()

    getStopid: -> Promise.resolve(@stopid)

    setStopid: (value) ->
      if @stopid is value then return
      @stopid = value

    getAmount: -> Promise.resolve(@amount)

    setAmount: (value) ->
      if @amount is value then return
      @amount = value

    getOffset: -> Promise.resolve(@offset)

    setOffset: (value) ->
      if @offset is value then return
      @offset = value

    getSchedule: -> Promise.resolve(@schedule)

    setSchedule: (value) ->
      @schedule = value
      @emit 'schedule', value

    reLoadSchedule: ->
      env.logger.info "reloading"

      now = new Date();
      time = now;
      if @offset is 'undefined' && @offset isnt 0
        time = new Date(now.getTime() + (@offset * 60 * 1000))

      url = api + "&stopid=" + @stopid + "&limit=" + @amount + "&time=" + time.toISOString()

      ###

      Request.get url, (error, response, body) ->
        if error
          throw error
        data = JSON.parse(body)

        if data and data.Departures and data.Departures.length > 0
          departures = data.Departures;

          placeholderContent = "<div class=\"dvb\"><div class=\"stop\">" + data.Name + "</div><div class=\"clear\"></div><div class=\"head\"><div class=\"line caption col-1\">Linie</div><div class=\"target caption col-2\">Ziel</div><div class=\"minutes caption col-3\">Min.</div></div><div class=\"clear\"></div>"

          for i in [0...departures.length - 1] by 1
            hit = departures[i]
            arrivalTime = new Date(parseInt(if hit.RealTime then hit.RealTime.match(/\d+/)[0] else hit.ScheduledTime.match(/\d+/)[0]))
            arrivalTimeRelative = Math.round((arrivalTime - now) / 1000 / 60)
            row = "<div class=\"col-1\">" + hit.LineName + "</div><div class=\"col-2\">" + hit.Direction + "</div><div class=\"col-3\">" + arrivalTimeRelative + "</div><div class=\"clear\"></div>"
            placeholderContent = placeholderContent + row

          placeholderContent = placeholderContent + "</div>"

          env.logger.info "setting new schedule"

          #@setSchedule(placeholderContent)

      ###

    actions:
      loadSchedule:
        description: "turns the switch on"

    destroy: ->
      super()


  ####### ACTION HANDLER ######
  class VvoActionHandler extends env.actions.ActionHandler
    constructor: (@framework) ->

    loadSchedule: () ->
      env.logger.info "Melde gehorsamst: Ausführung!"
      return "IT WORKS"

    executeAction: (simulate) =>
      if simulate
        env.logger.info "Das ist nur eine Übung"
        return Promise.resolve(__("would log 42"))
      else
        @loadSchedule()
        return Promise.resolve(__("Auftrag ausgeführt"))




  ####### ACTION PROVIDER #######
  class VvoActionProvider extends env.actions.ActionProvider
    constructor: (@framework)->
      env.logger.info "VvoActionProvider meldet sich zum Dienst"
      return

    executeAction: (simulate) =>
      env.logger.info "VvoActionProvider meldet gehorsamst: Ausführung!"
      return

    parseAction: (input, context) =>
      match = null

      m = M(input, context)
        .match('doit')

      if m.hadMatch()
        match = m.getFullMatch()
        return {
          token: match
          nextInput: input.substring(match.length)
          actionHandler: new VvoActionHandler(@framework)
        }

  vvoPlugin = new VvoPlugin
  return vvoPlugin