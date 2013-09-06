
require 'wires'

require 'thread'
require 'socket'

require_relative "ircbot/user"
require_relative "ircbot/events"
require_relative "ircbot/handlers"
require_relative "ircbot/overrides"

module IRC
  class Bot
    
    def initialize(**kwargs, &block)
      kwargs.each_pair { |k,v| instance_variable_set("@#{k}",v) }
      instance_eval &block
      init_handlers
    end
    
    
    def handle(event, &block)
      Wires::Convenience.on ('irc_'+event.to_s), self, &block
    end
    
    
    def init_handlers
      handle :message do |event|
        IrcEvent.children
          .map    { |c| c.from_message(event) }
          .select { |x| x }
          .each   { |e| Wires::Channel.new(self).fire_and_wait e }
      end
      
      default_handlers
    end
    
    
    def connect!
      @socket = TCPSocket.open(@server, @port)
      
      nick @nick
      user @nick, 0, '*', (@realname or @nick)
      
      while (m = @socket.gets.match /^((?::(.+?) )?(\w+) (.*?)\r\n)$/)
        Wires::Channel.new(self).fire_and_wait \
          [:irc_message,
            *(m[4].split ' '),
            string:  m[1].rstrip,
            prefix:  m[2],
            command: m[3]]
      end
    end
    
    
    def send_command(cmd, *args)
      cmd = [cmd.to_s.upcase, *args].join(' ')
      @socket.puts(cmd+"\r")
      puts "\033[1m<< #{cmd}\033[22m"
    end
    
    
    def method_missing(meth, *args)
      @socket ?
        send_command(meth, *args) :
        super
    end
    
  end
end
