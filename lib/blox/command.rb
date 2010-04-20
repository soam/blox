module Blox

class Command
  def initialize(args, &block)
    @args = args
    @block = block
    check_args
  end

  attr_accessor :parent
  attr_accessor :source_location
  attr_reader :block

  def check_args    
  end

  def execute
    self
  end

  def notify_parent
    if @parent
      @parent.got_child(self) 
    end
  end

  def run
    v = execute
    notify_parent
    v
  end

  # allow command implementations to access the current context
  attr_accessor :context_proc
  def context
    @context_proc.call
  end

end

end
