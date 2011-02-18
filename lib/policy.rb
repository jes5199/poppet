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
          "orderings" => []
        }
      }
    end

    def resources
      @data["data"]["resources"]
    end

    def orderings
      @data["data"]["resources"]
    end

    def combine( other )
      Policy.new(
        :data => {
          :resources => combine_resources( self.resources, other.resources ),
          :orderings => combine_orderings( self.orderings, other.orderings ),
        }
      )
    end

    private
    def combine_resources(r1, r2)
      r1.dup.tap{|r|
        r2.each do |key, res|
          raise "duplicate resource key #{key}" if r[key]
          r[key] = res
        end
      }
    end

    def combine_orderings(p1, p2)
      p1 + p2
      # TODO: look for cycles
    end
  end
end
