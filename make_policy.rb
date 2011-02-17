require 'rubygems'
require 'json'
require 'lib/policy'
require 'lib/policy_maker'

settings = {
  :policy_makers => "policy_makers/*"
}

#TODO validate command line
inventory = JSON.parse( ARGV[0] ? File.read(ARGV[0]) : STDIN.read )
#TODO validate schema

policy = Poppet::Policy.new
Poppet::PolicyMaker.each(settings[:policy_makers]) do |policy_maker|
  policy = policy.combine( policy_maker.execute( inventory ) )
end

puts( JSON.dump( policy.data ) )

