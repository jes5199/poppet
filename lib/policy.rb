module Poppet
  class Policy
    attr_reader :data
    def initialize( data = Policy.empty_data )
      @data = data
      # TODO validate schema
    end

    def self.empty_data
      {
        "data" => {
          "resources" => {},
          "orders"    => []
        }
      }
    end

    def resources
      @data["data"]["resources"]
    end

    def orders
      @data["data"]["resources"]
    end

    def combine( other )
      Policy.new(
        :data => {
          :resources => combine_resources( self.resources, other.resources ),
          :orders => combine_orders( self.orders, other.orders ),
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

    def combine_orders(p1, p2)
      p1 + p2
      # TODO: look for cycles
    end
  end
end
