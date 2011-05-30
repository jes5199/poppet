require 'lib/execute'
module Helpers
  include Poppet::Execute::EscapeWithLittleE
  include Poppet::Execute::ExecuteWithLittleX
  include Poppet::Execute::SafeExecuteBlocks
end
