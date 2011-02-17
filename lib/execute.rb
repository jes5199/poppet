require 'lib/execute'

module Poppet
  module Execute
    def self.execute(command, input = "")
      output = IO.popen(command, "r+") do |io|
        io.print( input )
        io.close_write
        io.read
      end
      status = $?
      raise "got error code #{status} from #{command}" if status != 0
      output
    end
  end
end
