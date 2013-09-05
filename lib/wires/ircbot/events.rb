
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


class IrcBot
  def init_events
    
    on :irc_message, self do |event,bot|
      IrcEvent.children
        .map    { |c| c.from_message(event) }
        .select { |x| x }
        .each   { |e| Wires::Channel.new(bot).fire_and_wait e }
    end
    
    user_events
  end
  def user_events; end
end

