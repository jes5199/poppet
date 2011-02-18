require 'lib/storage'
require 'lib/execute'

settings = {
  "inventory" => 'public/inventory',
  "policy"    => 'public/policy',
  "name_by"   => ['hostname'],
}

by_time = File.join(settings["inventory"], "by_time", "*")
by_name = File.join(settings["inventory"], "by_name")
Poppet::Storage.name_by( by_time, settings["name_by"], by_name )

policy_by_time = File.join( settings["policy"], "by_time")
Poppet::Storage.map_files( by_time, 'ruby make_policy.rb', policy_by_time )
