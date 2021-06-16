# frozen_string_literal: true

module PicoRubeme

  class Environment
    def self.the_empty_environment
      Environment.new(nil)
    end

    def self.make_frame(variables, values)
      Frame.new(variables, values)
    end

    class Frame
      def initialize(variables = [], values = [])
        @bindings = variables.zip(values).to_h
      end

      def variables
        @bindings.keys
      end

      def values
        @bindings.values
      end

      def lookup(var)
        @bindings[var]
      end

      def add_binding(var, val)
        @bindings.merge!({var => val})
      end

      def set(var, val)
        @bindings[var] = value
      end
    end                         # end of Frame

    def initialize(base_env = nil)
      @frame = nil
      @enclosing_environment = base_env
    end

    attr_reader :enclosing_environment

    def first_frame
      @frame
    end

    def extend(vars, vals)
      if vars.size == vals.size
        new_env = Environment.new(self)
        new_env.set_frame!(Environment.make_frame(vars, vals))
        new_env
      elsif vars.size < vals.size
        raise SchemeSyntaxError, "too many arguments supplied: %s => %s" % [vars, vals]
      else
        raise SchemeSyntaxError, "too few arguments supplied: %s => %s" % [vars, vals]
      end
    end

    def lookup_variable_value(var)
      val = nil
      env = self
      while env
        val = env.first_frame && env.first_frame.lookup(var)
        break if val
        env = env.enclosing_environment
      end
      raise SchemeSyntaxError, "unbound variable: got=%s" % var if val.nil?
      val
    end

    def define_variable(var, val)
      if first_frame.nil?
        set_frame!(Environment.make_frame([var], [val]))
      else
        first_frame.add_binding(var, val)
      end
      var
    end

    def set_variable_value(var, val)
      curr = nil
      env = self
      while env
        curr = env.first_frame && env.first_frame.lookup(var)
        if curr
          env.first_frame.set(var, val)
          break
        else
          env = env.enclosing_environment
        end
      end
      raise SchemeSyntaxError, "unbound variable: got=%s" % var if curr.nil?
      val
    end

    protected

    def set_frame!(frame)
      @frame = frame
    end

  end                           # end of Environment
end
