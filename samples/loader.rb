#!/usr/bin/ruby -w

require 'blox'

module TestCommands

  class Foo < Blox::Command
    def visit
      puts "foo was run"
    end    
  end

  class Bar < Blox::BlockCommand
    def visit
      puts "bar was run at #{@source_location}"
    end

    def got_child(child)
      puts "Bar " + self.to_s + " was notified of child: " + child.to_s
    end
  end

end


module TestLanguage
  Blox::create_language(self, TestCommands)
end


class TestUser
  include TestLanguage

  def test
    filename = "test.dsl"
    File.open(File.join(File.dirname(__FILE__),filename)) { |f| 
      self.instance_eval(f.read, filename)
    }
  end
end


TestUser.new.test
