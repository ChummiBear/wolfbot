require 'socket'
require 'logger'
require 'discordrb'

module Wolfbot
  class Twitch < Channel
    attr_reader :logger, :running, :socket

    def initialize(*args)
      super
      @socket = nil
    end

    def send(message)
      logger.info "< #{message}"
      socket.puts(message)
    end

    def run
      channel = Wolfbot.config.settings['twitch']['channel']
      ready = IO.select([socket])

      ready[0].each do |s|
        line = s.gets
        #match = line.match(/^:(.+)!(.+) PRIVMSG #(.+) :(.+)$/)
        match = line.match(/^@badges=(.+)color=(.+)display-name=(.+)emotes=(.+)id=(.+)mod=(.+)room-id=(.+)sent-ts=(.+)subscriber=(.+)tmi-sent-ts=(.+)turbo=(.+)user-id=(.+)user-type=(.+):(.+)!(.+) PRIVMSG #(.+) :(.+)$/)
        message = match && match[17]
        usertype = match && match[13]
        badges = match && match[1]

        if line =~ /^PING :tmi.twitch.tv/
          send "PONG :tmi.twitch.tv"
        end
        if message =~ /^!hello/
          user = match[14]
          logger.info "USER COMMAND: #{user} - !hello"
          send "PRIVMSG ##{channel} :Hello, #{user}"
        end
        if message =~ /^!announce/
          user = match[14]
          
          param = message.match(/^!announce (.+)/)
          param = param && param[1]

          channel = Wolfbot.config.settings['twitch']['channel']
          discbot_client_id = Wolfbot.config.settings['discord']['clientid']
          discbot_channel_id = Wolfbot.config.settings['discord']['channelid']
          discbot_token = Wolfbot.config.settings['discord']['token']

          if badges =~ /^broadcaster/ || usertype =~ /^mod/
            logger.info "USER COMMAND: #{user} - !announce"
            logger.info "Server: https://discordapp.com/oauth2/authorize?client_id=#{discbot_client_id}&scope=bot&permissions=147456"
            logger.info "Connecting to channel #{discbot_channel_id}"

            discbot = Discordrb::Bot.new token: discbot_token, client_id: discbot_client_id
            discbot.run :async

            message = "@everyone LIVE #{param} https://www.twitch.tv/#{channel}"
            discbot.send_message(discbot_channel_id, message)
            logger.info "TO DISCORD: #{message}"
            send "PRIVMSG ##{channel} :Annnouncment sent to Discord, thanks #{user}!"
            discbot.stop
          else
            logger.info "USER COMMAND: #{user} - !announce"
            send "PRIVMSG ##{channel} :Sorry #{user}, you must be the channel owner or a moderator to use this command!"
          end
        end                

        logger.info "> #{line}"
      end
    end

    def stop
      @running = false
    end
        
    private

    def initialize_channel
      username = Wolfbot.config.settings['twitch']['username']
      password = Wolfbot.config.settings['twitch']['password']
      channel = Wolfbot.config.settings['twitch']['channel']

      logger.info "Preparing to connect to Twitch as #{username}..."

      @socket = TCPSocket.new('irc.chat.twitch.tv', 6667)
      @running = true

      socket.puts("PASS #{password}")
      socket.puts("NICK #{username}")

      logger.info 'Connected...'

      send "JOIN ##{channel}"
      logger.info "JOINED channel ##{channel}"

      send "CAP REQ :twitch.tv/tags"
      logger.info "Twitch tags enabled"
    end
  end
end