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
      @log = []
      method = self.class.action_for(name)
      if method
        [send( method ), @log]
      end
    end

    def change(name, actual)
      @actual = actual
      @really = Really.new
      @log = []
      method = self.class.action_for(name)
      if method
        [send( method ), @log]
      end
    end

    def log(command, start_time, stop_time)
      @log << {
        "command"    => command,
        "start_time" => start_time,
        "stop_time"  => stop_time
      }
    end

    def really(&blk)
      @really.really do
        blk.call
      end
    end

    def execute( command )
      start_time = Time.now
      really do
        Poppet::Execute.execute( command )
      end
      stop_time = Time.now
      log(command, start_time, stop_time)
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
