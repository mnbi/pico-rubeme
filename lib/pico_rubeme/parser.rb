# frozen_string_literal: true

module PicoRubeme

  def self.parser
    Parser.new
  end

  class Parser < Component
    def parse(lexer)
      []
    end
  end
end
