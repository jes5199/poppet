require 'rubygems'
require 'json'
require 'lib/resource'
require 'lib/implementor'

module Poppet
  class Implementor
    class Dispatcher
      attr :resource

      def initialize( resource_json, options )
        @resource = Poppet::Resource.new( resource_json )
        @options = options
      end

      def subimplementor
        raise "virtual"
      end

      def execute(*args)
        imp_file = File.join(@options["imp_directory"], resource.data["Type"], subimplementor + ".rb") # TODO: smarter executable finding, extract into lib
        imp = Poppet::Implementor.new( imp_file )
        JSON.dump( imp.execute( *args ) )
      end

    end
  end
end
