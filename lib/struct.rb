module Poppet
  module Struct
    def self.by_keys(data, keys)
      keys.each do |key|
        raise "bad type: #{data.class}" unless data.is_a?(Hash) || data.is_a?(Array)
        raise "bad key: #{key.inspect}" if data.is_a?(Hash) && ! key.is_a?(String)
        raise "bad key for array: #{key.inspect}" if data.is_a?(Array) && ! key.is_a?(Integer)
        data = data[key]
      end
      data
    end
  end
end
