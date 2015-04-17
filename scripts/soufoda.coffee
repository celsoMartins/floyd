module.exports = (robot) ->
  robot.hear /^\#?sou ?foda/i, (msg) ->
    msg.send "http://www.gifsengracados.com.br/wp-content/uploads/2011/03/gif-sou-foda.gif"