require 'lib/policy/applier'
require 'lib/execute'
require 'rubygems'
require 'json'

policy = JSON.parse( ARGV[0] ? File.read(ARGV[0]) : STDIN.read ) # TODO factor out this pattern
#TODO validate schema

applier = Poppet::Policy::Applier.new( policy )

applier.each do |res|
  imp = File.join("imp", res["type"] + ".rb") # TODO: smarter executable finding, extract into lib
  p Poppet::Execute.execute( imp, JSON.dump( [ "change", res ] ) )
  #TODO build a report
end
