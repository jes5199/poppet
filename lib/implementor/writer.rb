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

    class Action
      def really
        raise "virtual"
      end

      def execute( *command )
        puts command.inspect
        really do
          #TODO: actually execute the command
        end
      end
    end

    class Really < Action
      def really
        yield
      end
    end

    class Simulate < Action
      def really
        # noop
      end
    end
  end
end
