
class IrcEvent < Wires::Event
  @children = []
  class << self
    attr_reader :children
    def inherited(child)
      @children << child
      super
    end
  end
end


class IrcMessageEvent < IrcEvent
  def self.from_message(m); false; end
end


class IrcEndOfMotdEvent < IrcEvent
  def self.from_message(m)
    (m.command == '376') and \
    new prefix: m.prefix,
        target: m.args[0],
        text:   m.args[1..-1]
  end
end

class IrcPingEvent < IrcEvent
  def self.from_message(m)
    (m.command == 'PING') and \
    new sender: m.args[0],
        target:(m.args[1] or m.args[0])
  end
end


class IrcBot
  def init_events
    on :irc_message, self do |event|
      IrcEvent.children
        .map    { |c| c.from_message(event) }
        .select { |x| x }
        .each   { |e| Wires::Channel.new(self).fire_and_wait e }
    end
    
    default_events
    user_events
  end
  
  def default_events
    on :irc_ping, self do |e|
      pong e.target
    end
    
  end
  
  def user_events; end
end

