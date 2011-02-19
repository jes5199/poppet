require 'vendor/json_shape/json_shape'
module Poppet
  class Struct
    def self.by_keys(data, keys)
      self.new(data).by_keys(keys)
    end

    def initalize( data )
      @data = data
    end

    def by_keys( keys )
      data = @data
      keys.each do |key|
        raise "bad type: #{data.class}" unless data.is_a?(Hash) || data.is_a?(Array)
        raise "bad key: #{key.inspect}" if data.is_a?(Hash) && ! key.is_a?(String)
        raise "bad key for array: #{key.inspect}" if data.is_a?(Array) && ! key.is_a?(Integer)
        data = data[key]
      end
      data
    end

    def validate
      JsonShape.schema_check( @data, kind, schema )
    end
  end
end
