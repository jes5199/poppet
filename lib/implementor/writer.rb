require 'lib/implementor/implementation'

module Poppet
  class Implementor::Writer < Implementor::Implementation
    attr_reader :rules
    def initialize(rules)
      @rules = rules
      @known = {}
    end

    def simulate(rule, actual, desired)
      do_rules(actual, rule, Simulate.new, actual, desired)
    end

    def change(rule, actual, desired)
      do_rules(actual, rule, Really.new, actual, desired)
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
