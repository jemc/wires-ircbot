
require 'wires'
include Wires::Convenience

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
    
    
    def init_handlers
      on :message do |m| 
        m = IRC.parse_message m
        begin fire_and_wait m 
        rescue ArgumentError
        end
      end
      default_handlers
    end
    
    
    def connect!
      @socket = TCPSocket.open(@server, @port)
      
      nick @nick
      user @nick, 0, '*', (@realname or @nick)
      
      while (m = @socket.gets.match /^((?::(.+?) )?(\w+) (.*?)\r\n)$/)
        fire_and_wait [message:[
            *(m[4].split ' '),
            string:  m[1].rstrip,
            prefix:  m[2],
            command: m[3]]]
      end
    end
    
    
    def send_command(cmd, *args)
      args.map! { |x| x.to_s }
      cmd = [cmd.to_s.upcase, *args].join(' ')
      @socket.puts(cmd+"\r")
      puts "\033[1m<< #{cmd}\033[22m"
    end
    
    
    def method_missing(meth, *args)
      @socket and meth!=:to_a ?
        send_command(meth, *args) :
        super
    end
    
  end
end
