hubot-yam
=========

Yammer adapter for Hubot oauth2

## Description

This is the [Yammer](http://yammer.com) adapter for hubot that allows you to
send an tweet to your Hubot and he will send an tweet back with the response.

## Installation

* Add `hubot-yam` as a dependency in your hubot's `package.json`
* Install dependencies with `npm install`
* Run hubot with `bin/hubot -a yam`

### Note if running on Heroku

You will need to change the process type from `app` to `web` in the `Procfile`.

## Usage

You will need to set some environment variables to use this adapter.

### Heroku

    % heroku config:add HUBOT_YAM_TOKEN="token"
    % heroku config:add HUBOT_YAM_GROUP="your group"

### Non-Heroku environment variables

    % export HUBOT_YAM_TOKEN="token"
    % export HUBOT_YAM_GROUP="your group"

Then you will need to set the HTTP endpoint on Twitter to point to your server
and make sure the request type is set to `GET`.

## Contribute

Just send pull request if needed or fill an issue !

## License

see LICENSE
