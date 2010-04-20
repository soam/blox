#!/usr/bin/ruby -w

require 'blox'

#
# A simple demo to show how to traverse the AST created by blox
#


module TheCommands

  # look ma, no methods!

  class A < Blox::BlockCommand
  end

  class B < Blox::BlockCommand
  end

  class C < Blox::Command
  end

end

module TheLanguage
  Blox::create_language(self, TheCommands)
end

class Test
  include TheLanguage

  def foo
    a { 
      b {
        b {
          c
        }
        a {
          c
        }
      }
      a {
        a { 
          a {
            c
            c
          }
        }
      }
    }
  end


  def print_sexp(c, level)
    r = "(#{c.class.to_s}"
    if (c.is_a? Blox::BlockCommand)
      c.children.each { |child|
        r << "\n" << " " * level * 3
        r << print_sexp(child, level+1)
      }
    end
    r << ")"
  end

end

t = Test.new

puts t.print_sexp(t.foo, 1)
