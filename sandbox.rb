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
    sleep 2
    privmsg e.channel, case e.user.nick
      when @nick; "Don't worry, guys. I'm back."
      else;       "Welcome to #{e.channel}, #{e.user.nick}."
      end
  end
  
  handle :part do |e|
    sleep 2
    privmsg e.channel, "Aw...  I'm going to miss that user."
  end
  
end.connect!