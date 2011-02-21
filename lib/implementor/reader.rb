require 'lib/implementor/implementation'

module Poppet
  class Implementor::Reader < Implementor::Implementation
    def initialize(rules)
      @rules = rules
      @known = {}
    end

    def check( name, predicate )
      JsonShape.schema_check( self[name], predicate ) || true rescue false
    end

    def [](name)
      return @known[name] if @known[name]

      rules = @rules[name]
      do_rules(self, rules)
    end
  end
end
