require 'rubygems'
require 'json'
require 'lib/resource'
require 'lib/implementor'

module Poppet
  class Implementor
    class Subimp
      attr :resource

      def initialize( resource_json )
        @resource = Poppet::Resource.new( resource_json )
      end

      def subimplementor
        raise "virtual"
      end

      def execute(*args)
        imp_file = File.join(settings["imp"], res.data["Type"], subimplementor + ".rb") # TODO: smarter executable finding, extract into lib
        imp = Poppet::Implementor.new( imp_file )
        imp.execute( *args )
      end

    end
  end
end
