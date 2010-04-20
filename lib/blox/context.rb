module Blox

class Context
  def initialize()
    @command_stack = []
    @properties = {}
  end

  attr_accessor :command_stack 
  attr_accessor :properties
  
  def [](k)
    @properties[k]
  end

  def []=(k, v)
    @properties[k] = v
  end
  
end

end
