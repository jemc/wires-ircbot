
module IRC
  class Bot
    
    def privmsg(target, *msg)
      return if target==@nick # Don't try to send to self
      send_command :privmsg, "#{target} :#{msg.join ' '}"
    end
    
  end
end
