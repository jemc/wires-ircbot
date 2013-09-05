
require 'wires'

require 'thread'
require 'socket'

require_relative "ircbot/events"


module IRC
  class Bot
    
    def initialize(**kwargs, &block)
      kwargs.each_pair { |k,v| instance_variable_set("@#{k}",v) }
      instance_eval &block
      init_events
    end
    
    def connect!
      @socket = TCPSocket.open(@server, @port)
      
      nick @nick
      user @nick, 0, '*', (@realname or @nick)
      
      while @socket.gets =~ /^(?::(.+?) )?(\w+) (.*?)\r\n$/
        Wires::Channel.new(self).fire_and_wait \
          [:irc_message,*($3.split ' '),prefix:$1,command:$2]
      end
    end
    
    def command(cmd, *args)
      @socket.puts("#{cmd.to_s.upcase} #{args.join(' ')}")
    end
    
    def method_missing(meth, *args)
      @socket ?
        command(meth, *args) :
        super
    end
    
  end
end
