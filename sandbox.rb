$LOAD_PATH.unshift(File.expand_path("./lib", File.dirname(__FILE__)))
require 'wires/ircbot'

Wires::Hub.run

puts 'whup'
IRC::Bot.new do
  @nick     = '|jemc-testdroid|'
  @password = 'password'
  @server   = 'irc.freenode.net'
  @port     = 6667
  
  @channels = ['#wires']
  
  handle :message do |event|
    puts event.string
  end
  
  handle :privmsg do |event|
    privmsg event.channel, event.text
  end
  
end.connect!