# frozen_string_literal: true

module PicoRubeme

  def self.parser
    Parser::Parser.new
  end

  module Parser

    TAG = /\*(.+)\*/

    module Utils
      def ast?(list)
        list.instance_of?(Array) && list[0].instance_of?(String) && list[0].match?(TAG)
      end

      def ast_type(list)
        if list.instance_of?(Array) && list[0].instance_of?(String)
          md = list[0].match(TAG)
          md && md[1]
        end
      end

      def ast_type?(list, expected_type)
        type = ast_type(list)
        type && type == expected_type
      end

      def identifier(list)
        ast_type?(list, "identifier") && list[1]
      end

      def definition?(list)
        ast_type?(list[0], "identifier") && identifier(list[0]) == "define"
      end

      def not_implemented_yet(feature)
        raise NotImplementedYetError, feature
      end
    end

    require_relative "parser/phase1_parser"
    require_relative "parser/phase2_parser"

    class Parser < Component

      def initialize
        super()
        @components[:p1] = Phase1Parser.new
        @components[:p2] = Phase2Parser.new
      end

      def parse(lexer)
        return [] if lexer.nil?
        ast_program = ["*program*"]
        Kernel.loop {
          ast_program << @components[:p2].parse(@components[:p1].parse(lexer))
        }
        ast_program
      end
    end

  end                           # end of Parser (module)
end
