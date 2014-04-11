{Adapter, TextMessage} = require 'hubot'
{EventEmitter} = require 'events'
YammerPushAPI = require('yammer-push-api-client')
Util = require('util')

class Yam extends Adapter
  send: (envelope, strings...) ->
    console.log "RRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRR"
    @bot.send str for str in strings

  run: ->
    self = @
    options =
      token:   process.env.HUBOT_YAM_TOKEN
      group:  process.env.HUBOT_YAM_GROUP

    bot = new YamRealTime options, @robot

    bot.listen()

    #bot.on 'message', (userId, userData, message) ->
    #  console.log "%%%%%%%%%%%%%%%%%%%%%%"
    #  #user = @robot.brain.userForId userId, userData
    #  #@receive new TextMessage user, message
    #
    #bot.on 'alarm',(origin) ->
    #  console.log "%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%"

    #bot.listen()


exports.use = (robot) ->
  new Yam robot





class YamRealTime extends EventEmitter
  constructor: (options, robot) ->
    throw new Error "Not enough parameters provided. I need a key, a token" unless options.token?


    if options.group?
      botOptions = { type: "group", group: options.group }
      @groupId = options.group
    else
      botOptions = { type: "all" }

    @robot = robot
    @bot = YammerPushAPI.Client(options.token, botOptions)
    @bot.robot = @robot

  send: (message) ->
    # チャットにメッセージを送信する処理...

  listen: ->
    # チャットから継続的にメッセージを取得する処理
    # メッセージを取得したら...
    # @emit 'message', user, message
    #console.log robot
    #console.log @robot
    @bot.on("data", (data) ->
      console.log "************************************************"
      #console.log this.robot
      console.log data
      data.forEach (res) ->
        return unless res.data?
        console.log "hhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhh"
        if res.data.type == 'message'
          console.log "type is message"
          selfId =  res.data.data.meta.current_user_id
          messages = res.data.data.messages
          console.log messages
    )

    @bot.on("error", (data) ->
      console.log("Error received: " + JSON.stringify(data))
    )

    @bot.on("fatal", (data) ->
      console.log("Fatal error received: " + response)
    )

    @bot.start()

