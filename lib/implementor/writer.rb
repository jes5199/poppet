require 'lib/implementor/implementation'

module Poppet
  class Implementor::Writer < Implementor::Implementation
    def initialize(rules)
      @rules = rules
      @known = {}
    end

    def simulate(name, actual, desired)
      rules = @rules[name]
      do_rules(actual, rules, Simulate.new, actual, desired)
    end

    def change(name, actual, desired)
      rules = @rules[name]
      do_rules(actual, rules, Really.new, actual, desired)
    end

    class Really
      def really
        yield
      end

      def execute( *command )
        puts command.inspect # TODO
      end

    end

    class Simulate
      def really
        # noop
      end

      def execute( *command )
        puts command.inspect # TODO: logging, reporting
      end
    end
  end
end
