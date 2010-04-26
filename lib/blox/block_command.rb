module Blox

class BlockCommand < Command
  
  def initialize(args, &block)
    super(args, &block)
    @children = []
  end

  attr_accessor :children

  def visit_before_block
  end

  def visit_after_block
    self
  end

  def call_block
    # derived class can override to pass arguments, or in general do
    # whatever it wants with the block
    @block.call
  end

  def got_child(child_command)
    @children << child_command
  end

  def run
    visit
    visit_before_block
    call_block
    v = visit_after_block
    notify_parent
    v
  end  

end

end
