require 'open3'
require 'json'
require 'lib/policy'

module Poppet
  class PolicyMaker
    def self.each(dir)
      Dir.glob(dir) do |file|
        yield(self.new(file))
      end
    end

    def initialize(filename)
      @filename = filename
    end

    def execute( inventory, options = {} )
      json_inventory = JSON.dump( inventory )
      output, status = Open3.capture2(@filename, :stdin_data => json_inventory )

      raise "got error code #{status} from #{inventory}" if status != 0
      results = JSON.parse( stdout.read )
      Poppet::Policy.new( results )
    end
  end
end
