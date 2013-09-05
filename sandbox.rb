$LOAD_PATH.unshift(File.expand_path("./lib", File.dirname(__FILE__)))
require 'wires/ircbot'

on :irc_message do |event, bot|
  p [event.prefix, event.command, event.args.join(" ")]
end

on :irc_end_of_motd do |event, bot|
  # bot.join '#wires'
end

Wires::Hub.run
IRC::Bot.new(
  nick:     '|jemc-testdroid|',
  password: 'password',
  server:   'irc.freenode.net',
  port:     6667
).connect!