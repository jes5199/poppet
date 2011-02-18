require 'lib/storage'
require 'lib/execute'

settings = {
  "inventory" => 'public/inventory',
  "policy"    => 'public/policy',
  "name_by"   => ['hostname'],
}

inv_by_time = File.join(settings["inventory"], "by_time", "*")
inv_by_name = File.join(settings["inventory"], "by_name")
Poppet::Storage.name_by( inv_by_time, settings["name_by"], inv_by_name )

pol_by_time = File.join( settings["policy"], "by_time")
Poppet::Storage.map_files( inv_by_time, 'ruby make_policy.rb', pol_by_time )

pol_by_time_glob = File.join(settings["policy"], "by_time", "*")
pol_by_name = File.join(settings["policy"], "by_name")
Poppet::Storage.name_by(pol_by_time_glob, ["data", "name"], pol_by_name )
