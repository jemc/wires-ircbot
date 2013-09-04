
require 'wires'

require 'thread'
require 'socket'

require "#{File.dirname(__FILE__)}/ircbot/events"


class IrcEvent < Wires::Event; end
class IrcLineEvent < IrcEvent; end

class IrcBot
  
  def initialize(**kwargs)
    kwargs.each_pair { |k,v| instance_variable_set("@#{k}",v) }
    init_events
  end
  
  def connect!
    @socket = TCPSocket.open(@server, @port)
    
    nick @nick
    user @nick, 0, '*', (@realname or @nick)
    
    while line = @socket.gets.strip
      Channel(self).fire_and_wait [:irc_line,line:line]
    end
  end

  def method_missing(meth, *args)
    @socket ?
      @socket.puts("#{meth.to_s.upcase} #{args.join(' ')}") :
      super
  end
  
end
