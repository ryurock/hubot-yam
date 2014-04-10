{Adapter, TextMessage} = require 'hubot'
{EventEmitter} = require 'events'
YammerPushAPI = require('yammer-push-api-client')

class Yam extends Adapter
  send: (envelope, strings...) ->
    @bot.send str for str in strings

  run: ->
    options =
      token:   process.env.HUBOT_YAM_TOKEN
      group:  process.env.HUBOT_YAM_GROUP

    bot = new YamRealTime options, @robot


    bot.on("data", (data) ->
      console.log("new data received: " + JSON.stringify(data))
    )

    bot.on("error", (data) ->
      console.log("Error received: " + JSON.stringify(data))
    )

    bot.on("fatal", (data) ->
      console.log("Fatal error received: " + response)
    )

    bot.on 'message', (userId, userData, message) ->
      user = @robot.brain.userForId userId, userData
      @receive new TextMessage user, message

    bot.listen()

exports.use = (robot) ->
  new Yam robot

class YamRealTime extends EventEmitter
  constructor: (options, @robot) ->
    throw new Error "Not enough parameters provided. I need a key, a token" unless options.token?

    if options.group?
      botOptions = { type: "group", group: options.group }
      @groupId = options.group
    else
      botOptions = { type: "all" }

    @bot   = YammerPushAPI.Client(options.token, botOptions)


  send: (message) ->
    # チャットにメッセージを送信する処理...

  listen: ->
    # チャットから継続的にメッセージを取得する処理
    # メッセージを取得したら...
    # @emit 'message', user, message

    @bot.on("data", (data) ->
      console.log("new data received: " + JSON.stringify(data))
    )

    @bot.on("error", (data) ->
      console.log("Error received: " + JSON.stringify(data))
    )

    @bot.on("fatal", (data) ->
      console.log("Fatal error received: " + response)
    )

    @bot.start()

