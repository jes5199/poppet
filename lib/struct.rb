require 'vendor/json_shape/json_shape'
module Poppet
  class Struct
    def self.by_keys(data, keys)
      self.new(data).by_keys(keys)
    end

    def initialize( data )
      @data = data
      validate!
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
            "Parameters" => ["either", {"choices"   => ["array", "object"]} ],
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
