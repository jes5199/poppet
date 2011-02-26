require 'lib/policy/applier'
require 'lib/execute'
require 'rubygems'
require 'json'
require 'lib/changelog'

policy = JSON.parse( ARGV[0] ? File.read(ARGV[0]) : STDIN.read ) # TODO factor out this pattern

applier = Poppet::Policy::Applier.new( policy )

# TODO: put information about the policy into the changelog metadata
history = Poppet::Changelog.new
applier.each do |res|
  imp = File.join("imp", res["Type"] + ".rb") # TODO: smarter executable finding, extract into lib
  results = Poppet::Execute.execute( imp, JSON.dump( [ "change", res ] ) )
  o = Poppet::Changelog.new( JSON.parse( results ) )
  history = history.concat( o )
end
puts history.to_json
