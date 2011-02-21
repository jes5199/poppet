require 'lib/implementor/implementation'

module Poppet
  class Implementor::Checker < Implementor::Implementation
    def initialize(rules)
      @rules = rules
      @known = {}
    end

    def check(name, actual, desired)
      rules = @rules[name]
      do_rules(nil, rules, actual[name], desired[name])
    end
  end
end
