require 'vendor/json_shape/json_shape'
module Poppet
  # Here's the rules:
  #  anything that derives from Struct is basically a glorified JSON document.
  #  It's @data variable should be nothing but JSON-acceptable types: hashes, arrays, and scalars
  #  If it contains other valid structs inside, you can inflate them at access time (rather than storing a reference to a ruby object)
  #  Try to avoid mutating state that might be in other objects:
  #     Use (hash = hash.merge) instead of hash.update
  #     Use (array = array + [x]) instead of (array << x) or array.push(x)

  class Struct
    def self.by_keys(data, keys)
      self.new(data).by_keys(keys)
    end

    def initialize( data )
      @data = data
      validate!
    end

    def to_hash
      @data
    end

    def to_json
      to_hash.to_json
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

    def validate!
      JsonShape.schema_check( @data, kind, schema )
    end

    def self.schema
      {
        "struct" => ["object", {
          "members" => {
            "Type"       => "string",
            "Version"    => "string",
            "Parameters" => "object",
            "Metadata"   => ["optional", "object"],
          }
        }]
      }
    end

    def related_classes
      []
    end

    def schema
      (self.class.ancestors.map{|a| a.schema if a.respond_to?(:schema)}.compact + related_classes.map{|x| x.schema}).inject({}) do |r, sch|
        # TODO: check for collisions
        r.update(sch)
      end
    end

    def kind
      self.class.name.sub(/^.*::/, "").downcase.gsub('::', '/')
    end

    def self.schema_for( type, version, data_def, meta_def, parent = "struct", abstract = false )
      {
        type    => ["restrict", {"require" => [parent, "_#{type}_#{version}"] } ], # TODO: build versioned eithers
        "_#{type}_#{version}" => ["object",
          {
            "members" =>
              { "Parameters" => "_#{type}_Parameters_#{version}",
                "Metadata"   => "_#{type}_Metadata_#{version}",
                "Type"       => ( abstract ? "string" : ["literal", type] ),
                "Version"    => ["literal", version.to_s],
              },
          } ],
        "_#{type}_Parameters_#{version}" => data_def,
        "_#{type}_Metadata_#{version}" => meta_def,
      }
    end
  end
end
