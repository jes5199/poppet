require 'lib/implementor'
require 'vendor/json_shape/json_shape'

module Poppet
  class Implementor::Implementation
    private
    def do_rules( res, rules, *args )
      r = res
      Array(rules).each do |rule|
        if rule.is_a?(Hash)
          rule.each do |key, rule_part|
            if ! r.nil?
              val = r[key]
              begin
                JsonShape.schema_check( val, rule_part )
              rescue => e
                r = nil
              end
            end
          end
        elsif rule.respond_to? :call
          r = rule.call( *args )
        else
          raise ArgumentError, "I don't understand #{rule.class}"
        end
        return nil if r.nil?
      end
      return r
    end

  end
end
