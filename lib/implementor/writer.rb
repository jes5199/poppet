require 'lib/execute'

module Poppet
  class Implementor::Writer
    attr_reader :desired, :actual

    def initialize(desired)
      @desired = desired
    end

    def self.actions(*args)
      @actions ||= {}
      if args.last.is_a?(Hash)
        args.pop.each do |name, method|
          @actions[name.to_s] = method.to_sym
        end
      end
      args.each do |name|
        @actions[name.to_s] = name.to_sym
      end
    end

    def self.action_list
      @actions.keys
    end

    def action_list
      self.class.action_list
    end

    def self.action_for(name)
      @actions[name.to_s]
    end


    def simulate(name, actual)
      @actual = actual
      @really = Simulate.new
      method = self.class.action_for(name)
      send( method ) if method
    end

    def change(name, actual)
      @actual = actual
      @really = Really.new
      method = self.class.action_for(name)
      send( method ) if method
    end

    def really(&blk)
      @really.really do
        blk.call
      end
    end

    def execute( command )
      really do
        Poppet::Execute.execute( command )
      end
    end

    class Really
      def really
        yield
      end
    end

    class Simulate
      def really
        # noop
      end
    end

  end
end
