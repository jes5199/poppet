require 'json_shape'

describe "JsonShape.schema_check" do
  describe "the anything type" do
    it "should validate strings" do
      JsonShape.schema_check( "x", "anything" )
    end
  end

  describe "the literal type" do
    it "should match literal matches" do
      JsonShape.schema_check( "x", ["literal", "x"] )
      JsonShape.schema_check( {"x"=>"y"}, ["literal", {"x"=>"y"}] )
    end

    it "should cope with false" do
      JsonShape.schema_check( false, ["literal", false] )
      lambda { JsonShape.schema_check( true, ["literal", false] ) }.should raise_error
    end

    it "should not match if the literal does not match" do
      lambda { JsonShape.schema_check( "x", ["literal", {"x" => "y"}] ) }.should raise_error
      lambda { JsonShape.schema_check( {"x"=>"y"}, ["literal", {"x"=>"z"}] ) }.should raise_error
      lambda { JsonShape.schema_check( 1, ["literal", "1"] ) }.should raise_error
    end
  end

  describe "the 'string' type" do
    it "should validate strings" do
      JsonShape.schema_check( "x", "string" )
    end
    it "should reject numbers" do
      lambda { JsonShape.schema_check( 1, "string" ) }.should raise_error
    end
    it "should reject objects" do
      lambda { JsonShape.schema_check( {}, "string" ) }.should raise_error
    end
    it "should reject null" do
      lambda { JsonShape.schema_check( nil, "string" ) }.should raise_error
    end
    it "should reject arrays" do
      lambda { JsonShape.schema_check( ["a"], "string" ) }.should raise_error
    end
    it "should reject bools" do
      lambda { JsonShape.schema_check( true, "string" ) }.should raise_error
      lambda { JsonShape.schema_check( false, "string" ) }.should raise_error
    end

    describe "with parameters" do
      it "should validate strings" do
        JsonShape.schema_check( "x", ["string", {}] )
      end
    end
  end

  describe "the range predicate" do
    it "should reject strings" do
      lambda { JsonShape.schema_check( "1", ["range", {}] ) }.should raise_error
    end

    it "should accept numbers in the range" do
      JsonShape.schema_check(   1, ["range", {"limits" => [0,3]}] )
      JsonShape.schema_check(   0, ["range", {"limits" => [0,3]}] )
      JsonShape.schema_check(   3, ["range", {"limits" => [0,3]}] )
      JsonShape.schema_check( 2.8, ["range", {"limits" => [0,3]}] )
      JsonShape.schema_check( 3.0, ["range", {"limits" => [0,3]}] )
    end

    it "should reject numbers out of the range" do
      lambda { JsonShape.schema_check(  -1, ["range", {"limits" => [0,3]}] ) }.should raise_error
      lambda { JsonShape.schema_check(   4, ["range", {"limits" => [0,3]}] ) }.should raise_error
      lambda { JsonShape.schema_check( 3.1, ["range", {"limits" => [0,3]}] ) }.should raise_error
    end
  end

  describe "the array type" do
    it "should accept arrays" do
      JsonShape.schema_check(  [1], "array" )
    end
    it "should accept arrays of the right type" do
      JsonShape.schema_check(  [1], ["array", {"contents" => "number"}] )
    end
    it "should reject arrays of the wrong type" do
      lambda { JsonShape.schema_check(  [[]], ["array", {"contents" => "number"}] ) }.should raise_error
    end
    it "should allow tests on array length" do
      JsonShape.schema_check(  [1], ["array", {"length" => ["literal", 1]}] )
      lambda { JsonShape.schema_check(  [1], ["array", {"length" => ["literal", 2]}] ) }.should raise_error
    end
  end

  describe "the either type" do
    it "should accept any one of the given subtypes" do
      JsonShape.schema_check( [], ["either", {"choices" => ["array", "number"]}] )
      JsonShape.schema_check(  1, ["either", {"choices" => ["array", "number"]}] )
    end

    it "should reject an unlisted subtype" do
      lambda{ JsonShape.schema_check(  false, ["either", {"choices" => ["array", "number"]}] ) }.should raise_error
    end
  end

  describe "the enum type" do
    it "should accept any of the given values" do
      JsonShape.schema_check(    "hello", ["enum", {"values" => ["hello", "goodbye"]}] )
      JsonShape.schema_check(  "goodbye", ["enum", {"values" => ["hello", "goodbye"]}] )
    end
    it "should reject any other value" do
      lambda { JsonShape.schema_check(    "elephant", ["enum", {"values" => ["hello", "goodbye"]}] ) }.should raise_error
      lambda { JsonShape.schema_check(            {}, ["enum", {"values" => ["hello", "goodbye"]}] ) }.should raise_error
    end
  end

  describe "the tuple type" do
    it "should accept an array of the given types" do
      JsonShape.schema_check( ["a", 1, [2]], ["tuple", {"elements" => ["string", ["range", {"limits" => [0,1]}], ["array", {"contents" => "number" }]  ]}] )
    end

    it "should not accept anything that isn't an array" do
      lambda {
        JsonShape.schema_check( {}, ["tuple", {"elements" => ["string", ["range", {"limits" => [0,1]}], ["array", {"contents" => "number" }]  ]}] )
      }.should raise_error
    end
    it "should not accept an array that is too short" do
      lambda {
        JsonShape.schema_check( ["a", 1], ["tuple", {"elements" => ["string", ["range", {"limits" => [0,1]}], ["array", {"contents" => "number" }]  ]}] )
      }.should raise_error
    end
    it "should not accept an array that is too long" do
      lambda {
        JsonShape.schema_check( ["a", 1, [2], 5], ["tuple", {"elements" => ["string", ["range", {"limits" => [0,1]}], ["array", {"contents" => "number" }]  ]}] )
      }.should raise_error
    end
    it "should not accept an array where an entry has the wrong type" do
      lambda {
        JsonShape.schema_check( ["a", 1, ["b"]], ["tuple", {"elements" => ["string", ["range", {"limits" => [0,1]}], ["array", {"contents" => "number" }]  ]}] )
      }.should raise_error
    end
    it "should allow optional elements at the end" do
      JsonShape.schema_check( ["a", 1], ["tuple", {"elements" => ["string", ["range", {"limits" => [0,1]}], ["optional", ["array", {"contents" => "number" }]]  ]}] )
      JsonShape.schema_check( ["a", 1, [2]], ["tuple", {"elements" => ["string", ["range", {"limits" => [0,1]}], ["optional", ["array", {"contents" => "number" }]]  ]}] )
    end
  end
  describe "the integer type" do
    it "should accept integers" do
      JsonShape.schema_check( 1, "integer" )
    end
    it "should reject floats" do
      lambda{ JsonShape.schema_check( 1.0, "integer" ) }.should raise_error
    end
    it "should reject strings" do
      lambda{ JsonShape.schema_check( "1", "integer" ) }.should raise_error
    end
  end

  describe "the object type" do
    it "should accept an object" do
      JsonShape.schema_check( {}, "object" )
    end

    it "should accept an object with the correct members" do
      JsonShape.schema_check( {"a" => 1}, ["object", {"members" => {"a" => "integer" } } ] )
    end

    it "should reject an object with missing members" do
      lambda { JsonShape.schema_check( {"a" => 1}, ["object", {"members" => {"a" => "integer", "b" => "integer" } } ] ) }.should raise_error
    end

    it "should reject an object with incorrect members" do
      lambda { JsonShape.schema_check( {"a" => 1}, ["object", {"members" => {"a" => "string" } } ] ) }.should raise_error
    end

    it "should accept an object with missing members if they are of type undefined" do
      JsonShape.schema_check( {"a" => 1}, ["object", {"members" => {"a" => "integer", "b" => "undefined" } } ] )
    end

    it "should accept an object with missing members if they are optional" do
      JsonShape.schema_check( {"a" => 1}, ["object", {"members" => {"a" => "integer", "b" => ["optional", "integer"] } } ] )
    end

    it "should reject an object with extra members" do
      lambda { JsonShape.schema_check( {"a" => 1, "b" => 2}, ["object", {"members" => {"a" => "integer" } } ] ) }.should raise_error
    end
  end

  describe "the dictionary type" do
    it "should accept an object" do
      JsonShape.schema_check( {}, "dictionary" )
    end

    it "should accept values of the correct type" do
      JsonShape.schema_check(  {"a" => 1}, ["dictionary", {"contents" => "number"}] )
    end

    it "should reject values of the wrong type" do
      lambda { JsonShape.schema_check(  {"a" => []}, ["dictionary", {"contents" => "number"}] ) }.should raise_error
    end

    it "should respect custom types" do
      JsonShape.schema_check(  {"a" => 1}, ["dictionary", {"contents" => "foo"}], {"foo" => "number"} )
    end
  end

  describe "the boolean type" do
    it "should accept true" do
      JsonShape.schema_check( true, "boolean" )
    end
    it "should accept false" do
      JsonShape.schema_check( false, "boolean" )
    end
    it "should reject other values" do
      lambda{ JsonShape.schema_check( 1, "boolean" ) }.should raise_error
    end
  end

  describe "the null type" do
    it "should accept null" do
      JsonShape.schema_check( nil, "null" )
    end
    it "should reject other values" do
      lambda{ JsonShape.schema_check( 1, "null" ) }.should raise_error
    end
  end

  describe "the restrict type" do
    it "should accept a value that satisfies multiple requirements" do
      JsonShape.schema_check( 2,
        ["restrict",
          {
            "require" => [
              "integer",
              ["range", {"limits" => [ 1, 5] } ],
              ["range", {"limits" => [-2, 2] } ],
              ["enum",  {"values" => [-2, 2] } ]
            ]
          }
        ]
      )
    end
    it "should reject a value that fails to satisfy a requirement" do
      lambda {
        JsonShape.schema_check( 2,
          ["restrict",
            {
              "require" => [
                "integer",
                ["range", {"limits" => [ 1,   5] } ],
                ["range", {"limits" => [-2,   2] } ],
                ["enum",  {"values" => [-2, nil] } ]
              ]
            }
          ]
        )
      }.should raise_error
    end
    it "should reject a value that satisfies a rejection constraint" do
      lambda {
        JsonShape.schema_check( 2,
          ["restrict",
            {
              "reject" => [
                ["range", {"limits" => [-2,   2] } ],
                ["enum",  {"values" => [-2, nil] } ]
              ]
            }
          ]
        )
      }.should raise_error
    end

    it "should accept a value that satisfies requirements and avoids rejections" do
      JsonShape.schema_check( 2,
        ["restrict",
          {
            "require" => [
              "integer",
              ["range", {"limits" => [ 1, 5] } ],
              ["range", {"limits" => [-2, 2] } ],
              ["enum",  {"values" => [-2, 2] } ]
            ],
            "reject" => [
              ["range", {"limits" => [-2, 1.9] } ],
              ["enum",  {"values" => [-2, nil] } ]
            ]
          }
        ]
      )
    end

    it "should reject a value that satisfies requirements but violates a rejection rule" do
      lambda {
        JsonShape.schema_check( 2,
          ["restrict",
            {
              "require" => [
                "integer",
                ["range", {"limits" => [ 1, 5] } ],
                ["range", {"limits" => [-2, 2] } ],
                ["enum",  {"values" => [-2, 2] } ]
              ],
              "reject" => [
                ["range", {"limits" => [-2, 1.9] } ],
                ["enum",  {"values" => [-2,   2] } ]
              ]
            }
          ]
        )
      }.should raise_error
    end

    it "should reject a value that fails to satisfy requirements but doesn't violate a rejection rule" do
      lambda {
        JsonShape.schema_check( 2,
          ["restrict",
            {
              "require" => [
                "integer",
                ["range", {"limits" => [ 1,   5] } ],
                ["range", {"limits" => [-2, 1.9] } ],
                ["enum",  {"values" => [-2,   2] } ]
              ],
              "reject" => [
                ["range", {"limits" => [-2, 1.9] } ],
                ["enum",  {"values" => [-2, nil] } ]
              ]
            }
          ]
        )
      }.should raise_error
    end

  end

  describe "named types" do
    it "should work" do
      JsonShape.schema_check( 2, "foo", { "foo" => "integer" } )
    end

    it "should enforce the refered type" do
      lambda { JsonShape.schema_check( 2, "foo", { "foo" => "array" } ) }.should raise_error
    end

    it "should work recursively" do
      JsonShape.schema_check( 2, "foo", { "foo" => "bar", "bar" => ["integer", {"range" => [-1,2]}] } )
      lambda { JsonShape.schema_check( 3, "foo", { "foo" => "bar", "bar" => ["range", {"limit" => [-1,2] } ] } ) }.should raise_error
    end

    it "should not allow undefined types" do
      lambda { JsonShape.schema_check( 2, "bar", { "foo" => "integer" } ) }.should raise_error
    end
  end
end
