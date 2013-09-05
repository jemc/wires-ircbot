
require 'wires'

require 'thread'
require 'socket'

require_relative "ircbot/events"
require_relative "ircbot/overrides"

module IRC
  class Bot
    
    def initialize(**kwargs, &block)
      kwargs.each_pair { |k,v| instance_variable_set("@#{k}",v) }
      instance_eval &block
      init_events
    end
    
    
    def handle(event, &block)
      Wires::Convenience.on ('irc_'+event.to_s), self, &block
    end
    
    
    def init_events
      handle :message do |event|
        IrcEvent.children
          .map    { |c| c.from_message(event) }
          .select { |x| x }
          .each   { |e| Wires::Channel.new(self).fire_and_wait e }
      end
      
      default_events
    end
    
    
    def connect!
      @socket = TCPSocket.open(@server, @port)
      
      nick @nick
      user @nick, 0, '*', (@realname or @nick)
      
      while @socket.gets =~ /^(?::(.+?) )?(\w+) (.*?)\r\n$/
        Wires::Channel.new(self).fire_and_wait \
          [:irc_message,*($3.split ' '),sender:$1,command:$2]
      end
    end
    
    
    def send_command(cmd, *args)
      @socket.puts("#{cmd.to_s.upcase} #{args.join(' ')}\r")
      puts "<< #{cmd.to_s.upcase} #{args.join(' ')}"
    end
    
    
    def method_missing(meth, *args)
      @socket ?
        send_command(meth, *args) :
        super
    end
    
  end
end
