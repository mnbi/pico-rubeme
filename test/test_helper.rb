# frozen_string_literal: true

require "singleton"

$LOAD_PATH.unshift File.expand_path("../lib", __dir__)
require "pico_rubeme"

class Utils
  include PicoRubeme::AST
  include Singleton
end

require "minitest/autorun"
