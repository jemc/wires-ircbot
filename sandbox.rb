$LOAD_PATH.unshift(File.expand_path("./lib", File.dirname(__FILE__)))
require 'wires/ircbot'

Wires::Hub.run

IRC::Bot.new do
  @nick     = '|jemc-testdroid|'
  @password = 'password'
  @server   = 'irc.freenode.net'
  @port     = 6667
  
  handle :message do |event|
    p [event.prefix, event.command, event.args.join(" ")]
  end
  
  handle :end_of_motd do |event|
    join '#wires'
  end
  
end.connect!