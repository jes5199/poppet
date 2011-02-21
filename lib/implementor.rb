require 'lib/execute'
require 'lib/resource'
require 'lib/success'
require 'lib/events'
require 'rubygems'
require 'json'

module Poppet
  class Implementor
    def check( resource ) # bool
      Poppet::Sucess.new( execute( ["check", resource.data] ) )
    end

    def survey( resource ) # resource
      Poppet::Resource.new( execute( ["survey", resource.data] ) )
    end

    def simulate( resource ) # events, resource
      events, resource = execute( ["simulate", resource.data] )
      [ Poppet::Events.new( events ), Poppet::Resource.new( resource ) ]
    end

    def change( resource ) # events, resource
      events, resource = execute( ["change", resource.data] )
      [ Poppet::Events.new( events ), Poppet::Resource.new( resource ) ]
    end

    def initialize(path)
      @path = path
    end

    private
    def execute( data )
      JSON.parse( Poppet::Execute.execute( @path, JSON.dump( data ) ) )
    end
  end
end

