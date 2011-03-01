#!/usr/bin/ruby

require 'rubygems'
require 'json'
facts = JSON.parse( STDIN.read.to_s )

hostname = facts["Parameters"]["hostname"]

print <<-JSON
{
  "Version": "0",
  "Type": "policy",
  "Parameters": {
    "resources": {
      "my directory": {
        "Version": "0",
        "Type": "directory",
        "Parameters": {
          "exists": true,
          "path": "/tmp/poppet"
        }
      },
      "my file": {
        "Version": "0",
        "Type": "file",
        "Parameters": {
          "path": "/tmp/poppet/file",
          "content": "Hello, world, from #{hostname}"
        },
        "Metadata": {
          "after": ["my directory"]
        }
      },
      "my file2": {
        "Version": "0",
        "Type": "file",
        "Parameters": {
          "path": "/tmp/poppet/file2",
          "content": "file2"
        },
        "Metadata": {
          "nudge": ["my file"]
        }
      }
    }
  }
}
JSON

