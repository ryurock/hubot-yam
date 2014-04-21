{Adapter, TextMessage} = require 'hubot'
{EventEmitter} = require 'events'
YammerPushAPI = require('yammer-push-api-client')
{Yammer} = require('yammer')
Util = require('util')
require('colors')

class Yam extends Adapter
  send: (envelope, strings...) ->
    console.log "your hubot script respond !!!!!!!!!!!!!!!"
    @bot.send envelope, str for str in strings

  run: ->
    self = @
    options =
      token:  process.env.HUBOT_YAM_TOKEN
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
    yam = new Yammer { access_token : @bot.oauthToken }
    yamParams =
      body : message

    yamParams.replied_to_id = envelope.room.thread_id unless envelope.message.options?

    if envelope.message.options?
      if envelope.message.options.direct_to_id?
        console.log "------------- private message send -------------"
        yamParams.direct_to_id = envelope.message.options.direct_to_id

    yam.createMessage yamParams, (err, data, res) ->
      console.log "[Notified] send"

  listen: ->
    @bot.on("data", (data) ->
      robot = this.robot

      data.forEach((res) ->
        return unless res.data? and res.data.type == 'message'

        data       = res.data.data
        references = data.references
        meta       = data.meta
        messages   = data.messages

        messages.forEach((message) ->

          threadId  = message.thread_id
          text      = message.body.plain
          userId    = message.sender_id

          userName  = ''
          room      = { thread_id : threadId }
          for reference, index in references
            userName = reference.name if reference.type == 'user' and userId == reference.id
            if reference.type == 'group'
              room.group_id  = reference.id        if reference.id?
              room.full_name = reference.full_name if reference.full_name?
              room.name      = reference.name      if reference.name?

          user =
            name      : userName
            id        : userId
            room      : room

          user = robot.brain.userForId userId, user
          console.log '============================ scripts/* method respond fire  ============================'.yellow
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
