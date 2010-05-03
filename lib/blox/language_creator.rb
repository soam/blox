module Blox

#
# All the lambdas and fun stuff is in here.
#
class LanguageCreator
  def initialize()
    @name_func = lambda { |x| default_name_func x }
  end

  #
  # Create the functions and default context accessor
  #
  def create_language(target_module, command_module)
    # context
    create_context_accessor target_module

    # and the functions
    classes = get_command_classes(command_module)
    classes.each { |klass| 
      create_command_function(target_module, klass)
    }
  end

  #
  # Create the function for a Command or a BlockCommand
  # 
  def create_command_function(target_module, command_class)
    func_name = @name_func.call(command_class)
    func = <<EOF
      def #{func_name}(*args, &block)
        Blox::LanguageCreator.command_function_helper(
          blox_get_context, caller[0], #{command_class.to_s}, args, &block)
      end
EOF
    target_module.module_eval func
  end

  # run the command
  def self.run_command(cmd)
    v = cmd.visit
    if cmd.is_a? BlockCommand
      cmd.visit_before_block
      cmd.call_block
      v = cmd.visit_after_block
    end
    cmd.notify_parent
    v
  end

  #
  # Does most of the work of the command function
  # 
  def self.command_function_helper(context, location, command_class, args, &block)
    cmd = command_class.new(args, &block)

    cmd.parent = context.command_stack.last
    cmd.source_location = location
    cmd.context_proc = lambda { blox_get_context }

    context.command_stack.push(cmd) if (cmd.is_a? BlockCommand)

    v = run_command(cmd)

    context.command_stack.pop if (cmd.is_a? BlockCommand)
    v
  end

  #
  # Create a simple context accessor
  #
  def create_context_accessor(target_module)
    # Using thread local storage until I think of something better...
    target_module.module_eval do
      def blox_get_context
        unless Thread.current[:context]
          #puts "Creating thread-local context for thread #{Thread.current.inspect}"
          Thread.current[:context] = Context.new
        end
        Thread.current[:context]
      end
    end
  end

  #
  # Find all Blox::Commands in this module tree
  #
  def get_command_classes(command_module)
    command_classes = []
    command_module.constants.each { |c| 
      m = command_module.to_s + "::" + c
      o = eval(m)
      if (o.is_a? Class and o < Command)
        command_classes << m
      elsif o.is_a? Module
        command_classes.concat get_command_classes(o)
      end
    }
    command_classes
  end

  #
  # Default class name -> function name translation -- throw away
  # module qualifiers and convert CamelCase to underscore_style
  #
  def default_name_func(klass)
    klass.to_s.split("::").last.gsub(/([a-z0-9])([A-Z])/, '\1_\2').downcase
  end

  # Set the name func; used to translate the fully qualified class
  # name to the function name.  This should be a string -> string
  # proc.
  def name_func=(name_func)
    if name_func
      @name_func = name_func
    end
  end

end

end
