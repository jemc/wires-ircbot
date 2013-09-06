$LOAD_PATH.unshift(File.expand_path("./lib", File.dirname(__FILE__)))
require 'wires/ircbot'

Wires::Hub.run

IRC::Bot.new do
  @nick     = '|jemc-testdroid|'
  @password = 'password'
  @server   = 'irc.freenode.net'
  @port     = 6667
  
  @channels = ['#wires']
  
  handle :message do |e|
    puts e.string
  end
  
  handle :privmsg do |e|
    privmsg e.channel, e.text
  end
  
  handle :join do |e|
    privmsg e.user, "Welcome to #{e.channel}, #{e.user}."
  end
  
  handle :part do |e|
    privmsg e.channel, "Aw...  I'm going to miss that user."
  end
  
end.connect!