# frozen_string_literal: true

require "fileutils"
require "readline"

module PicoRubeme

  class Repl < Component

    RUBEME_DATA_HOME = File.expand_path("rubeme", ENV["XDG_DATA_HOME"]) ||
                       File.expand_path("~/.rubeme")
    HISTORY_FILE = File.expand_path("rubeme_history", RUBEME_DATA_HOME)
    HISTORY_MAX = 100

    FileUtils.mkdir_p(RUBEME_DATA_HOME) unless FileTest.exist?(RUBEME_DATA_HOME)

    def self.start(prompt: "REPL> ", verbose: false)
      size = load_history
      if verbose
        puts "Load %d entries into the history." % size
      end

      msg = Repl.new(prompt: prompt, verbose: verbose).loop
      puts msg if msg

      size = save_history
      if verbose
        puts "Save %d entries from the history." % size
      end
    end

    def self.load_history
      if FileTest.exist?(HISTORY_FILE)
        File.readlines(HISTORY_FILE, chomp: true).each { |line|
          Readline::HISTORY << line
        }
        Readline::HISTORY.size
      else
        0
      end
    end

    def self.save_history
      prev_entries = []
      if FileTest.exist?(HISTORY_FILE)
        prev_entries = File.readlines(HISTORY_FILE, chomp: true)
      end

      candidates = Readline::HISTORY.find_all{|e| !e.empty?}
      entries = []

      candidates.each_with_index { |e, i|
        entries << e if e != prev_entries[i]
      }

      size = [entries.size, HISTORY_MAX].min
      offset = entries.size - size
      File.open(HISTORY_FILE, "a") { |f|
        size.times{|i| f.puts(entries[offset + i]) }
      }
      size
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

    def greeting
      puts version
    end

    def loop
      greeting

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
