module Poppet
  module Execute
    def self.execute(command, input = "")
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
      output = IO.popen(command, "r+") do |io|
        io.print( input )
        io.close_write
        io.read
      end
      status = $?
      status == 0
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
    end

    class Error < RuntimeError
    end
  end
end
