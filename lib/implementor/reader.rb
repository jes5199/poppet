require 'lib/implementor/implementation'

module Poppet
  class Implementor::Reader < Implementor::Implementation
    def initialize(rules)
      @rules = rules
      @known = {}
    end

    def [](name)
      return @known[name] if @known[name]

      rules = @rules[name]
      r = do_rules(self, rules)
      unless r.nil?
        @known[name] = r
      end
    end

    def to_hash
      Hash.new{|h,k| h[k] = self[k]}.merge( @known )
    end

    def merge( hash )
      to_hash.merge(hash)
    end

  end
end
