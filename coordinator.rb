require 'json'
require 'lib/policy'

inventory = JSON.parse(File.read($1))
#TODO validate schema

Poppet::Policy.each(settings[:policy]) do |policy|
  policy.execute( inventory )
end

