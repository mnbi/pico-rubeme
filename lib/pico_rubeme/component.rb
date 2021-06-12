# frozen_string_literal: true

module PicoRubeme
  class Component
    def self.version
      PicoRubeme.make_version(self.name)
    end

    attr_reader :verbose

    def initialize
      @verbose = false
      @components = {}
    end

    def verbose=(bool)
      @verbose = bool
      @components.each{|_, c| c.verbose = bool}
    end

    def version
      if @components.empty?
        self.class.version
      else
        vers = [self.class.version]
        comp_vers = @components.map{|_, c| c.version}
        vers << comp_vers unless comp_vers.empty?
        vers
      end
    end
  end
end
