

module IRC
  
  class IrcEvent < Wires::Event
    @children = []
    class << self
      attr_reader :children
      def inherited(child)
        super
        @children << child
        child.class_eval do
          define_singleton_method :from_message do |m| false end
        end
      end
    end
  end
  
  # Meta method for dry event definitions
  def self.def_event(name, parent_name: :event, &block)
    name        = ('irc_'+name       .to_s).camelcase
    parent_name = ('irc_'+parent_name.to_s).camelcase
    
    module_eval "class #{name} < #{parent_name}; end"
    
    const_get(name).class_eval do
      define_singleton_method :from_message, &block
    end if block
  end
  
  
  def_event :message
  
  def_event :end_of_motd do |m|
    (m.command == '376') and \
    new prefix: m.prefix,
        target: m.args[0],
        text:   m.args[1..-1].join(' ')[1..-1]
  end
  
  def_event :ping do |m|
    (m.command == 'PING') and \
    new sender: m.args[0],
        target:(m.args[1] or m.args[0])
  end
  
  
  class Bot
    def init_events
      on :irc_message, self do |event|
        IrcEvent.children
          .map    { |c| c.from_message(event) }
          .select { |x| x }
          .each   { |e| Wires::Channel.new(self).fire_and_wait e }
      end
      
      default_events
    end
    
    def default_events
      on :irc_ping, self do |e|
        pong e.target
      end
    end
    
    def handle(event, &block)
      Wires::Convenience.on ('irc_'+event.to_s), self, &block
    end
    
  end
  
  
end
