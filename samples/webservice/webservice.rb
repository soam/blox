#!/usr/bin/ruby -w

require 'blox'
require 'webrick'

#
# A toy webservice language, kind of in the style of sinatra 
# 
# Create a webrick server and route GET requests to ruby blocks.
#
module WebServiceCommands
  
  #
  # The server
  #
  class Server < Blox::BlockCommand

    def check_args
      @opts = @args[0]
      @opts = {} unless @opts
      @opts[:port] = 8888 unless @opts[:port]      

      # gah
      @opts[:Port] = @opts[:port]
    end

    def visit_before_block
      @server = WEBrick::HTTPServer.new(@opts)
      @server.mount_proc('/', Proc.new { |req,resp| serve_proc(req,resp) })
      trap('QUIT') { @server.stop }
    end

    def visit_after_block
      # all the get paths are set up; start the server
      puts "Starting server..."
      @server.start
    end

    def serve_proc(req, resp)
      @children.each do |child|
        if (child.is_a? Get and req.request_method == "GET")
          if (req.path =~ /^#{child.path}$/)
            context[:request] = req
            resp.body = child.block.call
            break
          end
        end
      end
    end

  end

  #
  # The GET command
  #
  class Get < Blox::Command
    def check_args
      @path = @args[0]
    end

    attr_reader :path

  end

  #
  # Use this inside a get block to get a (rather stupidly) scrubbed
  # version of the form input
  #
  class CleanedQuery < Blox::Command
    def visit
      key = @args[0]
      input = context[:request].query[key]
      if input
        input.gsub(/[^a-zA-Z]/, '')
      else
        ''
      end
    end
  end

  #
  # Some simple form building commands
  # 
  class Form < Blox::BlockCommand
    def visit_before_block
      @markup = "<form action='#{@args[0][:action]}' method='#{@args[0][:method]}'>"
    end

    def got_child(child)
      @markup << child.markup
    end

    def visit_after_block
      @markup << "</form>"
    end
  end


  class TextInput < Blox::Command
    def markup
      "<input type='text' name='#{@args[0]}'/>"
    end
  end

  class Text < Blox::Command
    def markup
      @args[0]
    end
  end

  class Submit < Blox::Command
    def markup
      "<input type='submit' value='#{@args[0]}'/>"
    end
  end

end

# use the commands to make the DSL
module WebServiceLanguage
  Blox::create_language(self, WebServiceCommands)
  
  # Override blox's class-local context and use thread-local context
  # instead
  def blox_get_context
    unless Thread.current[:context]
      puts "Creating thread-local context for thread #{Thread.current.inspect}"
      Thread.current[:context] = Blox::Context.new
    end
    Thread.current[:context]
  end
end

# dump the language into this namespace
include WebServiceLanguage
