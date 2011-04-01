require 'lib/implementor'
require 'lib/settings'

settings = Poppet::Settings.new

action, resource_data = JSON.parse( ARGV[0] ? File.read(ARGV[0]) : STDIN.read ) # TODO factor out this pattern
res = Poppet::Resource.new( resource_data )

imp_file = File.join(settings["imp"], res.data["Type"] + ".rb") # TODO: smarter executable finding, extract into lib
imp = Poppet::Implementor.new( imp_file )

puts imp.execute( [action, resource_data] ).to_json
