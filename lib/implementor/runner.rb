module Poppet
  module Implementor
    module Runner
      def self.run( imp_class, readers )
        @readers = readers
        command, desired_json = JSON.parse( STDIN.read )

        desired = Poppet::Resource.new( desired_json )
        @imp = imp_class.new(desired)

        self.do(command)
      end

      def do( command, extra = {} )
        case command
          when "check"    then check!
          when "survey"   then survey!
          when "simulate" then simulate!
          when "change"   then change!
        end
      end

      def check!
        # raise if anything would modify the system.
        Poppet::Execute.forbid_unsafe_execution!
        @imp.run!
        {}
      end

      def survey!
        Poppet::Execute.forbid_unsafe_execution!
        values = Hash.new
        @readers.each do |name|
          values[name.to_s] = @imp.send(name)
        end
        Poppet::Resource.new({}, values)
      end

      def simulate!
        Poppet::Execute.disable_unsafe_execution!
        change!
      end

      def change!
        @imp.run!
        survey!
      end

    end
  end
end
