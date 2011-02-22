#!/usr/bin/ruby

print <<-JSON
{
  "version": "0",
  "type": "policy",
  "data": {
    "resources": {
      "my directory": {
        "version": "0",
        "type": "directory",
        "data": {
          "exists": true,
          "path": "/tmp/poppet"
        }
      },
      "my file": {
        "type": "file",
        "version": "0",
        "type": "file",
        "data": {
          "path": "/tmp/poppet/file",
          "content": "Hello, world"
        }
      }
    }
  }
}
JSON

