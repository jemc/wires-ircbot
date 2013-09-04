$LOAD_PATH.unshift(File.expand_path("./lib", File.dirname(__FILE__)))
require 'wires/ircbot'

on :irc_line do |event, bot|
  p event.line
end

Wires::Hub.run
IrcBot.new(
  nick:     '|jemc-testdroid|',
  password: 'password',
  server:   'irc.freenode.net',
  port:     6667
).connect!