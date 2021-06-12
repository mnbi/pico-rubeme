# frozen_string_literal: true

module PicoRubeme

  def self.printer
    Printer.new
  end

  class Printer < Component
    def print(obj)
      pp obj
    end
  end
end
