require 'lib/execute'
require 'lib/resource'
require 'lib/success'
require 'lib/changelog'
require 'rubygems'
require 'json'

module Poppet
  class Implementor
    def check( resource )
      Poppet::Sucess.new( execute( ["check", resource.data] ) )
    end

    def survey( resource )
      Poppet::Resource.new( execute( ["survey", resource.data] ) )
    end

    def simulate( resource )
      results = execute( ["simulate", resource.data] )
      Poppet::Changelog.new( results )
    end

    def change( resource )
      results = execute( ["change", resource.data] )
      Poppet::Changelog.new( results )
    end

    def nudge( resource )
      results = execute( ["nudge", resource.data] )
      Poppet::Changelog.new( results )
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

