#!/usr/bin/env ruby

require "slack-ruby-bot"

require "net/http"
require "nokogiri"
require "time"
require "./web/web"
require "./web/rootme_parsing_error"
require "./web/rootme_request_error"

require "singleton"
require "./database/database"

require "./controller/controller"


module RootmeBot
  class App < SlackRubyBot::App
  end

  class Ranking < SlackRubyBot::Commands::Base
    command "ranking"
    command "score"

    def self.call(client, data, _match)
      client.message text: RootmeBot::Rootme.ranking(), channel: data.channel
    end
  end

  class Add < SlackRubyBot::Commands::Base
    command "add"

    def self.call(client, data, _match)
      words = data.text.split(" ")

      if words[0] == "add"
        slack_pseudo = words[1]
        rootme_pseudo = words[2]
      elsif words[1] == "add"
        slack_pseudo = words[2]
        rootme_pseudo = words[3]
      else
        client.message text: "`add`: invalid command", channel: data.channel
        return
      end

      if slack_pseudo == nil || rootme_pseudo == nil
        client.message text: "`add`: parameter(s) missing", channel: data.channel
        return
      end

      message = RootmeBot::Rootme.add_user(slack_pseudo, rootme_pseudo)
      client.message text: message, channel: data.channel
    end
  end

  class Remove < SlackRubyBot::Commands::Base
    command "remove"

    def self.call(client, data, _match)
      words = data.text.split(" ")

      if words[0] == "remove"
        slack_pseudos = words[1..(words.size-1)]
      elsif words[1] == "remove"
        slack_pseudos = words[2..(words.size-1)]
      else
        client.message text: "`remove`: invalid command", channel: data.channel
        return
      end

      if slack_pseudos.size == 0
        msg = "`remove`: missing parameter(s), add at least a slack pseudo"
        client.message text: msg, channel: data.channel
        return
      end
    
      for slack_pseudo in slack_pseudos
        message = RootmeBot::Rootme.remove_user(slack_pseudo)
        client.message text: message, channel: data.channel
      end
    end
  end

  class Default < SlackRubyBot::Commands::Base
    match(/^(?<bot>[\w[:punct:]@<>]*)$/)  # to match when no command given
    command "about"
    command "help"

    def self.call(client, data, _match)
      message  = "Supported commands:\n"
      message += "`ranking`: display the ranking of all registered users\n"
      message += "`add slack_pseudo rootme_pseudo`: register a user for the ranking\n"
      message += "`delete slack_pseudo`: delete an user from the ranking\n"
      message += "v0.1 - https://github.com/vmarquet/slack-bot-rootme/"
      client.message text: message, channel: data.channel
    end
  end
end

SlackRubyBot.configure do |config|
  config.send_gifs = false
end


RootmeBot::App.instance.run
