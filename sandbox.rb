$LOAD_PATH.unshift(File.expand_path("./lib", File.dirname(__FILE__)))
require 'wires/ircbot'

IRC::Bot.new do
  @nick     = '|jemc-testdroid|'
  @password = 'password'
  @server   = 'irc.freenode.net'
  @port     = 6667
  
  @channels = ['#wires']
  
  on :message do |e|
    puts e.string
  end
  
  on :privmsg do |e|
    privmsg e.channel, e.text
  end
  
  on :join do |e|
    sleep 1
    privmsg e.channel, case e.user.nick
      when @nick; "Don't worry, guys. I'm back."
      else;       "Welcome to #{e.channel}, #{e.user.nick}."
      end
  end
  
  on :part do |e|
    sleep 1
    privmsg e.channel, "Aw...  I'm going to miss that user."
  end
  
end.connect!