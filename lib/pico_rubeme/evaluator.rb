# frozen_string_literal: true

module PicoRubeme

  def self.evaluator
    Evaluator.new
  end

  class Evaluator < Component
    def eval(obj, env)
      obj
    end
  end
end
