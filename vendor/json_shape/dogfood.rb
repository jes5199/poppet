require 'rubygems'
require 'json'
require 'json_shape'

schema = JSON.parse( File.read( "json_shape.shape.json" ) )

JsonShape.schema_check( schema, "json_shape", schema )

draft = JSON.parse( File.read( "draft.js" ) )
JsonShape.schema_check( draft, "json_shape", schema )
