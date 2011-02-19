#!/usr/bin/ruby

print <<-JSON
{
  "version": 0,
  "data": {
    "resources": {
      "my directory": {
        "type": "directory",
        "path": "/tmp/poppet"
      },
      "my file": {
        "type": "file",
        "path": "/tmp/poppet/file",
        "content": "Hello, world"
      }
    },
    "orderings": ["my directory", "my file"]
  }
}
JSON

