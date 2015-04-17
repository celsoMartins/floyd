# Show the commiters from a repo
#
# add HUBOT_GITHUB_USER to your heroku env 
# the HUBOT_GITHUB_USER should map to your account, not the bot account
# the HUBOT_BOT_GITHUB_USER should map to the bot github username
# the HUBOT_BOT_GITHUB_PASS should map to the bot github password

# developed by http://github.com/fellix - Crafters Software Studio

module.exports = (robot) ->
  robot.hear /^repo commiters (.*)$/i, (msg) ->
      read_contributors msg, (repository, commits) ->
          max_length = if commits.length > 20 then 20 else commits.length
          
          result = "#{repository}\n"
          times = 0
          for commit in commits[0..max_length]
            result += "[#{commit.login}] #{commit.contributions}"
            result += if times == 0 then " :trophy:\n" else "\n"
            times += 1
          
          msg.send result
              
  robot.hear /^repo top-commiter (.*)$/i, (msg) ->
      read_contributors msg, (repository, commits) ->
          top_commiter = null
          result = "#{repository}\n"
          for commit in commits
            top_commiter = commit if top_commiter == null
            top_commiter = commit if commit.contributions > top_commiter.contributions 
          result += "[#{top_commiter.login}] #{top_commiter.contributions} :trophy:"
          msg.send result
  
  
read_contributors = (msg, response_handler) ->
    repo = msg.match[1].toLowerCase()
    repo = "#{process.env.HUBOT_GITHUB_USER}/#{repo}" unless repo.indexOf("/") > -1
    bot_github_user = process.env.HUBOT_BOT_GITHUB_USER 
    bot_github_pass = process.env.HUBOT_BOT_GITHUB_PASS
    auth = new Buffer("#{bot_github_user}:#{bot_github_pass}").toString('base64')
    url = "https://api.github.com/repos/#{repo}/contributors"
    
    msg.http(url)
      .headers(Authorization: "Basic #{auth}", Accept: "application/json")
      .get() (err, res, body) ->
        if err
          msg.send "GitHub says: #{err}"
          return
        commits = JSON.parse(body)
        if commits.message
          msg.send "Achievement unlocked: [NEEDLE IN A HAYSTACK] repository #{commits.message}!"
        else if commits.length == 0
          msg.send "Achievement unlocked: [LIKE A BOSS] no commits found!"
        else
          response_handler "http://github.com/#{repo}", commits
