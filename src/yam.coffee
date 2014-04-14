{Adapter, TextMessage} = require 'hubot'
{EventEmitter} = require 'events'
YammerPushAPI = require('yammer-push-api-client')
{Yammer} = require('yammer')
Util = require('util')

class Yam extends Adapter
  send: (envelope, strings...) ->
    console.log "your hubot script respond !!!!!!!!!!!!!!!"
    @bot.send envelope, str for str in strings

  run: ->
    self = @
    options =
      token:   process.env.HUBOT_YAM_TOKEN
      group:  process.env.HUBOT_YAM_GROUP

    bot = new YamRealTime options, @robot

    bot.listen()

    @robot.on('error', (data) ->
      console.log 'received: error reason', data
    )

    @bot = bot
    self.emit 'connected'

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

    @bot = YammerPushAPI.Client(options.token, botOptions)
    @bot.robot = @robot

  send: (envelope, message) ->
    # チャットにメッセージを送信する処理...
    console.log envelope
    yam = new Yammer { access_token : @bot.oauthToken }

    yamParams =
      body : message
      replied_to_id : envelope.user.thread_id

    console.log yamParams

    #yam.createMessage yamParams, (err, data, res) ->
    #  console.log "[Notified] send"


  listen: ->
    # チャットから継続的にメッセージを取得する処理
    # メッセージを取得したら...
    @bot.on("data", (data) ->
      robot = this.robot

      data.forEach((res) ->
        return unless res.data? and res.data.type == 'message'

        data       = res.data.data
        references = data.references
        meta       = data.meta
        messages   = data.messages

        messages.forEach((message) ->
          userId    = message.sender_id
          userName  = ''
          for reference, index in references
            continue unless reference.type == 'user' and userId == reference.id
            userName = reference.name

          threadId = message.replied_to_id
          text     = message.body.plain

          user =
            name      : userName
            id        : userId
            thread_id : threadId

          user = robot.brain.userForId userId, user
          console.log '============================ myhubot/scripts/*の method respond /正規表現にデータが渡される/ ============================'
          robot.receive new TextMessage user, text
        )
      )
    )

    @bot.on("error", (data) ->
      console.log("Error received: " + JSON.stringify(data))
    )

    @bot.on("fatal", (data) ->
      console.log("Fatal error received: " + response)
    )

    @bot.start()
