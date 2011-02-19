module Poppet
  class Policy
    attr_reader :data
    def initialize( data = {}, name = nil )
      @data = self.class.empty_data.merge(data)
      @data["data"]["name"] = name if name
      # TODO validate schema
    end

    def self.empty_data
      {
        "data" => {
          "resources" => {},
          "orderings" => [],
          "name"      => ""
        }
      }
    end

    def resources
      @data["data"]["resources"]
    end

    def orderings
      @data["data"]["orderings"]
    end

    def name
      @data["data"]["name"]
    end

    def combine( other )
      Policy.new(
        "data" => {
          "resources"=> combine_resources( self.resources, other.resources ),
          "orderings"=> combine_orderings( self.orderings, other.orderings ),
          "name"     => self.name || other.name,
        }
      )
    end

    private
    def combine_resources(r1, r2)
      dups = r1.keys - r2.keys
      raise "duplicate resource keys #{dups.inspect}" if ! dups.empty?
      r1.merge(r2)
    end

    def combine_orderings(p1, p2)
      p1 + p2
      # TODO: look for cycles
    end
  end
end
