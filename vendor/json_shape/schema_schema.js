{
  "schema" : [ "dictionary", {"contents": "definition"} ],
  "definition" : [ "either", {"choices": ["definition_atom", "definition_singleton", "definition_pair"] } ],

  "builtin_type" : [ "enum", {
    "values": ["string", "number", "boolean", "null", "undefined", "array", "object", "anything",
               "literal", "optional", "integer", "enum", "range",
               "tuple", "dictionary", "either", "restrict"
              ]
  } ],

  "definition_atom" : [ "either", {
    "choices": [ "custom_type", "builtin_type_with_optional_parameters", "builtin_type_without_parameters" ]
  } ],

  "definition_singleton" : [ "tuple", {
    "elements": [ "definition_atom" ]
  } ],

  "definition_pair" : ["either", {"choices" :
    [
      [ "tuple", {"elements": [ "builtin_type_without_parameters", ["literal",{}]  ] } ],

      [ "tuple", {"elements": [ ["literal", "literal"]   , "anything"              ] } ],
      [ "tuple", {"elements": [ ["literal", "optional"]  , "definition"            ] } ],

      [ "tuple", {"elements": [ ["literal", "array"]     , "array_parameters"      ] } ],
      [ "tuple", {"elements": [ ["literal", "object"]    , "object_parameters"     ] } ],
      [ "tuple", {"elements": [ ["literal", "dictionary"], "dictionary_parameters" ] } ],
      [ "tuple", {"elements": [ ["literal", "restrict"]  , "restrict_parameters"   ] } ],

      [ "tuple", {"elements": [ ["literal", "enum"]      , "enum_parameters"       ] } ],
      [ "tuple", {"elements": [ ["literal", "range"]     , "range_parameters"      ] } ],
      [ "tuple", {"elements": [ ["literal", "tuple"]     , "tuple_parameters"      ] } ],
      [ "tuple", {"elements": [ ["literal", "either"]    , "either_parameters"     ] } ]
    ]
  } ],

  "custom_type" : ["restrict", {
    "require": ["string"],
    "reject":  ["builtin_type"]
  } ],

  "builtin_type_without_parameters" : ["enum", {
    "values": ["string", "number", "boolean", "null", "undefined", "anything", "integer"]
  } ],

  "builtin_type_with_optional_parameters" :  ["enum", {
    "values": ["array", "object", "dictionary", "restrict"]
  } ],

  "builtin_type_with_mandatory_parameters" : ["enum", {
    "values": ["literal", "optional", "enum", "range", "tuple", "either"]
  } ],

  "optional_definition": [ "optional", "definition" ],
  "optional_definitions": [ "optional", ["array", {"contents": "definition"} ] ],

  "array_parameters": [ "object", {"members": {
    "contents": "optional_definition",
    "length":   "optional_definition"
  } } ],

  "object_parameters": [ "object", {"members": {
    "members": ["optional", ["dictionary", { "contents": "definition"} ] ],
    "allow_extra":   ["optional", "boolean"],
    "allow_missing": ["optional", "boolean"]
  } } ],

  "dictionary_parameters": [ "object", {"members": {"contents": "optional_definition" } } ],

  "restrict_parameters": [ "object", {"members": {
    "require" : "optional_definitions",
    "reject"  : "optional_definitions"
  } } ],

  "enum_parameters": [ "object", {"members": {
    "values" : ["array", {"contents": "anything"}]
  } } ],

  "range_parameters": [ "object", {"members": {
    "limits" : ["tuple", {"elements": ["number", "number"]}]
  } } ],

  "tuple_parameters": [ "object", {
    "members" : {
      "elements" : ["array", {"contents": "definition"}]
    }
  } ],

  "either_parameters": [ "object", {
    "members" : {
      "choices" : ["array", {"contents": "definition"}]
    }
  } ]

}
