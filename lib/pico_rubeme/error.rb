# frozen_string_literal: true

module PicoRubeme
  class Error < StandardError
    def initialize(msg)
      super(msg)
    end
  end

  class SchemeSyntaxError < Error
    def initialize(msg)
      super("Scheme syntax error: " + msg)
    end
  end

  class UnexpectedTokenTypeError < Error
    def initialize(msg)
     super("unexpected token type: " + msg)
    end
  end

  class MissingRightParenthesisError < Error
    def initialize
      super("missing right parenthesis")
    end
  end

  class NotImplementedYetError < Error
    def initialize(feature)
      msg = "not implemented yet: %s" % feature
      super(msg)
    end
  end
end
