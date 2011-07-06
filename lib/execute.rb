module Poppet
  module Execute
    def self.forbid_unsafe_execution!
      @saved_execution_forbidden = []
      @execution_forbidden = :raise
    end

    def self.disable_unsafe_execution!
      @saved_execution_forbidden = []
      @execution_forbidden = :suspend
    end

    def self.execute(command, input = "")
      @execution_forbidden ||= false
      raise Denied if @execution_forbidden == :raise
      return if @execution_forbidden == :suspend

      output = IO.popen(command, "r+") do |io|
        io.print( input )
        io.close_write
        io.read
      end
      status = $?
      raise self::Error, "got error code #{status} from #{command}" if status != 0
      output
    end

    def self.execute_test( command, input = "" )
      begin
        execute( command_input )
        true
      rescue self::Error
        false
      end
    end

    def self.safe( &blk )
      @saved_execution_forbidden ||= []
      @execution_forbidden ||= false
      @saved_execution_forbidden.push @execution_forbidden
      @execution_forbidden = false

      blk.call

      ensure
      @execution_forbidden = @saved_execution_forbidden.pop
    end

    def self.shellescape(str)
      # An empty argument will be skipped, so return empty quotes.
      return "''" if str.empty?

      str = str.dup

      # Process as a single byte sequence because not all shell
      # implementations are multibyte aware.
      str.gsub!(/([^A-Za-z0-9_\-.,:\/@\n])/n, "\\\\\\1")

      # A LF cannot be escaped with a backslash because a backslash + LF
      # combo is regarded as line continuation and simply ignored.
      str.gsub!(/\n/, "'\n'")

      return str
    end

    module SafeExecuteBlocks
      def safe( &blk )
        Poppet::Execute.safe( &blk )
      end
    end

    module EscapeWithLittleE
      def e( string )
        Poppet::Execute.shellescape( string.to_s )
      end
    end

    module ExecuteWithLittleX
      def x( *args )
        Poppet::Execute.execute( *args )
      end

      def xt( string )
        Poppet::Execute.execute_test( *args )
      end

      def x?( string )
        Poppet::Execute.execute_test( *args )
      end
    end

    class Error < RuntimeError
    end

    class Denied < RuntimeError
    end
  end
end
