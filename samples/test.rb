#!/usr/bin/ruby -w

require 'blox'

module TestCommands

  class Foo < Blox::Command
    def visit
      puts "foo was run at #{@source_location}"
      return "Hello, #{@args[0]}!"
    end    
  end

  class Bar < Blox::BlockCommand
    def visit
      puts "bar was run at #{@source_location}"
    end

    def got_child(child)
      puts "Bar was notified of child: " + child.to_s
    end
  end

  class Baz < Blox::BlockCommand
    def call_block
      @args.each { |x| 
        @block.call(x)
      }
    end
  end

end


module TestLanguage
  Blox::create_language(self, TestCommands)
end


class TestUser
  include TestLanguage

  def test
    bar {
      bar {
        value = foo "world"
        puts "foo says: #{value}"

        baz 1,2,3 do |x|
          puts "x = #{x}"
        end
      }
    }
  end
end

TestUser.new.test
