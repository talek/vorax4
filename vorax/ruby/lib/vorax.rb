# encoding: UTF-8

require 'rubygems' unless defined? Gem
require 'logger'
require 'childprocess'

# The main Vorax namespace. Everything related to VoraX is part
# of this module.
module Vorax

  # Sets the logger to be used for debug purposes.
  # @param logger [Logger] the logger object.
  def self.logger=(logger)
    @logger = logger
  end

  # Get the current logger.
  def self.logger
    @logger
  end

  # Log a debug entry.
  # @param message [String] the message to be logged.
  def self.debug(message)
    if @logger
      @logger.add(Logger::DEBUG, nil, 'rby') { message }
    end
  end

  # Get a hash which can be used to store additional 
  # properties. This is used by Vorax vim logic in order
  # to cache values accross vim function calls.
  def self.extra
    @extra || @extra = Hash.new
  end

  # Raised when another SqlPlus is already executing.
  class AnotherExecRunning < StandardError; end

  # Raised when the platform is not supported (see cancel)
  class PlatformNotSupported < StandardError; end

end

require 'vorax/version.rb'
require 'vorax/vorax_io.rb'
require 'vorax/sqlplus.rb'
require 'vorax/base_funnel.rb'
require 'vorax/utils.rb'
require 'vorax/profiles_manager.rb'
require 'vorax/oradoc.rb'
require 'vorax/output/html_funnel.rb'
require 'vorax/output/html_convertor.rb'
require 'vorax/output/vertical_convertor.rb'
require 'vorax/output/zip_convertor.rb'
require 'vorax/output/pagezip_convertor.rb'
require 'vorax/output/tablezip_convertor.rb'
require 'vorax/parser/parser.rb'
require 'vorax/parser/conn_string.rb'
require 'vorax/parser/target_ref.rb'
require 'vorax/parser/stmt_inspector.rb'
require 'vorax/parser/plsql_walker.rb'
require 'vorax/parser/region.rb'
require 'vorax/parser/declare_item.rb'
require 'vorax/parser/grammars/statement.rb'
require 'vorax/parser/grammars/alias.rb'
require 'vorax/parser/grammars/column.rb'
require 'vorax/parser/grammars/declare.rb'
require 'vorax/parser/grammars/record_typ.rb'
require 'vorax/parser/grammars/subprog.rb'
require 'vorax/parser/grammars/probe_composite.rb'
require 'vorax/parser/grammars/probe_subprog.rb'
require 'vorax/parser/grammars/probe_forloop.rb'
require 'vorax/parser/grammars/probe_end.rb'
require 'vorax/parser/grammars/ids.rb'
require 'vorax/parser/plsql_structure.rb'
