require 'open3'
require 'json'
module Poppet
  class Policy
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

      results = JSON.parse( stdout.read )
    end
  end
end
