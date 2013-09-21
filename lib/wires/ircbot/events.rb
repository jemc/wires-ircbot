

module IRC
  
  def self.parse_message m
    if m.command=='376'
      return [end_of_motd:[
        prefix:  m.prefix,
        target:  m.args[0],
        text:    m.args[1..-1].join(' ')[1..-1]
      ]]
    end
    
    if m.command=='PING'
      return [ping:[
        prefix:  m.args[0],
        target: (m.args[1] or m.args[0])
      ]]
    end
    
    if m.command=='PRIVMSG'
      return [privmsg:[
        user:   (User.new m.prefix),
        channel: m.args[0],
        text:    m.args[1..-1].join(' ')[1..-1]
      ]]
    end
    
    if m.command=='JOIN'
      return [join:[
        user:   (User.new m.prefix),
        channel: m.args[0]
      ]]
    end
    
    if m.command=='PART'
      return [part:[
        user:   (User.new m.prefix),
        channel: m.args[0],
        text:    m.args[1..-1].join(' ')[1..-1]
      ]]
    end
  end
end
