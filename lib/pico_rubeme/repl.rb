# frozen_string_literal: true

require "readline"

module PicoRubeme

  class Repl < Component

    def self.start(prompt: "REPL> ", verbose: false)
      msg = Repl.new(prompt: prompt, verbose: verbose).loop
      puts msg if msg
    end

    def initialize(prompt:, verbose: false)
      super()
      @components[:parser] = PicoRubeme.parser
      @components[:evaluator] = PicoRubeme.evaluator
      @components[:printer] = PicoRubeme.printer
      @env = PicoRubeme.setup_environment

      init_components

      self.verbose = verbose
      @prompt = prompt
    end

    def loop
      second_prompt = "." * (@prompt.length - 1) + " "
      msg = Kernel.loop {
        begin
          source = read_source(second_prompt)
        rescue EOFError => _
          break "Bye!"
        else
          next if source.nil?
        end

        begin
          lexer = Lexer.new(source)
          nodes = @components[:parser].parse(lexer)
          result = @components[:evaluator].eval(nodes, @env)
          @components[:printer].print(result)
        rescue Error => e
          puts e.message
          next
        end
      }
      msg
    end

    private

    def init_components
    end

    def read_source(second_prompt = ">> ")
      source = Readline::readline(@prompt, true)
      raise EOFError if source.nil?

      until match_parenthesis(source)
        more_source = Readline::readline(second_prompt, true)
        if more_source.nil?
          source = nil
          break
        else
          source += (more_source + " ")
        end
      end

      source
    end

    def match_parenthesis(str)
      count = count_characters(str, ["(", ")"])
      count["("] == count[")"]
    end

    def count_characters(str, chars)
      count = chars.to_h{|ch| [ch, 0]}
      escaped = false
      in_string = false
      str.each_char { |rune|
        case rune
        when "\\"
          escaped = !escaped if in_string
        when '"'
          in_string = !in_string unless escaped
          escaped = false
        when *chars
          count[rune] += 1 unless in_string
        else
          escaped = false
        end
      }
      count
    end

  end                           # end of Repl
end
