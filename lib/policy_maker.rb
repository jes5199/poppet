require 'open3'
require 'json'
require 'lib/policy'
require 'lib/execute'

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
      Poppet::Execute.execute(@filename, :stdin_data => json_inventory )

      results = JSON.parse( stdout.read )
      Poppet::Policy.new( results )
    end
  end
end
