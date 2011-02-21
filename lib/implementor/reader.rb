require 'lib/implementor'
require 'vendor/json_shape/json_shape'

module Poppet
  class Implementor::Reader
    def initialize(rules)
      @rules = rules
      @known = {}
    end

    def find_rule_for(name, path = [])
      rules = @rules
      path.each{|n,matcher| rules = rules[n]["within"][matcher]}

      if rules[name]
        return [path, rules[name]]
      end

      rules.each do |n, desc|
        next if ! desc["within"]
        desc["within"].keys.each do |matcher|
          r = find_rule_for( name, path + [[n, matcher]] )
          return r if r
        end
      end
    end

    def check( name, predicate )
      JsonShape.schema_check( self[name], predicate ) || true rescue false
    end

    def [](name)
      return @known[name] if @known[name]

      path, desc = find_rule_for(name)

      path.each do |n,pr|
        return nil unless check(n,pr)
      end

      desc["read"].call

    end
  end
end
