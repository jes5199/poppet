require 'lib/implementor/implementation'

module Poppet
  class Implementor::Reader < Implementor::Implementation
    def initialize(rules)
      @rules = rules
      @known = {}
    end

    def [](name)
      return @known[name] if @known[name]

      rules = @rules[name]
      r = do_rules(self, rules)
      unless r.nil?
        @known[name] = r
      end
    end
  end
end
