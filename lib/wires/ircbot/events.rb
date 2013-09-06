

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
    new prefix:  m.prefix,
        target:  m.args[0],
        text:    m.args[1..-1].join(' ')[1..-1]
  end
  
  def_event :ping do |m|
    (m.command == 'PING') and \
    new prefix:  m.args[0],
        target: (m.args[1] or m.args[0])
  end
  
  def_event :privmsg do |m|
    (m.command == 'PRIVMSG') and \
    new user:    m.prefix,
        channel: m.args[0],
        text:    m.args[1..-1].join(' ')[1..-1]
  end
  
  def_event :part do |m|
    (m.command == 'PART') and \
    new user:    m.prefix,
        channel: m.args[0],
        text:    m.args[1..-1].join(' ')[1..-1]
  end
  
end
