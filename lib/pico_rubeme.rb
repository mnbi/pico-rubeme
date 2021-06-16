# frozen_string_literal: true

module PicoRubeme

  module Utils
    def not_implemented_yet(feature)
      raise NotImplementedYetError, feature
    end
  end

  require_relative "pico_rubeme/error"
  require_relative "pico_rubeme/version"
  require_relative "pico_rubeme/object"
  require_relative "pico_rubeme/lexer"
  require_relative "pico_rubeme/component"
  require_relative "pico_rubeme/ast"
  require_relative "pico_rubeme/parser"
  require_relative "pico_rubeme/environment"
  require_relative "pico_rubeme/evaluator"
  require_relative "pico_rubeme/printer"
  require_relative "pico_rubeme/repl"

  def self.setup_environment
    Environment.new
  end

  def self.run(files:, verbose: false)
    puts "not implemented yet"
  end
end
