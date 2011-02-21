require 'lib/struct'
module Poppet
  class Events < Struct
    def self.schema
      schema_for( "events", "0", ["object", {"members" => {"events" => ["array", {"members" => "event" }]} } ], "undefined" ).update \
      schema_for( "event", "0", ["object", {"members" => {
        "time"      => "string",
        "duration"  => "number",
        "command"   => "string",
        "original"  => "anything",
        "requested" => "anything",
        "result"    => "anything",
      } } ] )
    end
  end
end
