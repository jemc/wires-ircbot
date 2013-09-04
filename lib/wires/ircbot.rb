
require 'wires'

require 'thread'
require 'socket'


class IrcEvent < Wires::Event; end
class IrcLineEvent < IrcEvent; end

class IrcBot
  
  def initialize(**kwargs)
    kwargs.each_pair { |k,v| instance_variable_set("@#{k}",v) }
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
    @socket.puts("#{meth.to_s.upcase} #{args.join(' ')}")
  end
  
end
