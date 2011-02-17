require 'json'
require 'lib/policy_maker'

settings = {
  :policy_makers => "policy_makers/*"
}

#TODO validate command line
inventory = JSON.parse(File.read($1))
#TODO validate schema

policy = Policy.new
Poppet::PolicyMaker.each(settings[:policy_makers]) do |policy_maker|
  policy = policy.combine( policy_maker.execute( inventory ) )
end

puts( JSON.dump( policy.data ) )

