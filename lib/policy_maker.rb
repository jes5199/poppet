require 'open3'
require 'json'
require 'lib/policy'
require 'lib/execute'
require 'lib/storage'

module Poppet
  class PolicyMaker
    def self.each(dir)
      Poppet::Storage.glob(dir) do |file|
        yield(self.new(file))
      end
    end

    def initialize(filename)
      @filename = filename
    end

    def execute( inventory, options = {} )
      json_inventory = JSON.dump( inventory )
      data = Poppet::Execute.execute(@filename, :stdin_data => json_inventory )

      results = JSON.parse( data )
      Poppet::Policy.new( results )
    end
  end
end
