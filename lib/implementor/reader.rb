require 'lib/implementor'
module Poppet
  class Implementor::Reader
    def initialize(*rules)
      @rules = rules
    end
  end
end
