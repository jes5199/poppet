require 'rubygems'
require 'json'

settings = {
  "facts"            => './system_facts',
  "facts_version"    => 'git rev-parse HEAD',
  "imp"              => './imp',
  "imp_version"      => 'git rev-parse HEAD',
  "inventory"        => 'public/inventory',
  "inventory_server" => 'http://localhost:4567/inventory',
  "key_name"         => "local",
  "keys"             => "keys",
  "logs"             => 'public/logs',
  "name_by"          => ['hostname'],
  "passphrase"       => 'poppet',
  "policy"           => 'public/policy',
  "policy_makers"    => "policy_makers/*",
  "policy_server"    => 'http://localhost:4567/policy',
  "policy_version"   => 'git rev-parse HEAD',
  "public"           => 'public',
  "last_known_good"  => 'private/last_known_good',
}

puts settings.to_json
