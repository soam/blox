#!/usr/bin/ruby -w


require 'blox/command'
require 'blox/block_command'
require 'blox/context'
require 'blox/language_creator'

module Blox

def self.create_language(target_module, command_module)
  LanguageCreator::new.create_language(target_module, command_module)
end

end
