require 'lib/execute'

module Poppet
  class Settings #TODO: subclass of struct?
    def initialize( settings_prg = "ruby settings.rb" )
      @settings = JSON.parse( Poppet::Execute.execute( settings_prg ) )
    end

    def [](key)
      @settings[key]
    end
  end
end
