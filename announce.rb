require 'json'
require 'lib/http'


settings = {
  "server" => 'http://localhost:3000/inventory'
}

facts = {
  'hostname' => `hostname`,
}

# TODO get facts from directory of stuff
#   system_facts/flat/*
#   system_facts/structured/*

json = JSON.dump( facts )

Poppet::HTTP.post(settings["server"], json)


