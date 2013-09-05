$LOAD_PATH.unshift(File.expand_path("./lib", File.dirname(__FILE__)))
require 'wires/ircbot'

Wires::Hub.run

IRC::Bot.new do
  @nick     = '|jemc-testdroid|'
  @password = 'password'
  @server   = 'irc.freenode.net'
  @port     = 6667
  
  @channels = ['#wires']
  
  handle :message do |event|
    p [event.sender, event.command, event.args.join(" ")]
  end
  
  handle :end_of_motd do |event|
    @channels.each { |c| join c }
  end
  
  handle :privmsg do |event|
    p event.text
    privmsg event.target, event.text
  end
  
end.connect!