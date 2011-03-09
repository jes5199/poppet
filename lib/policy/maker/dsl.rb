require 'rubygems'
require 'json'
require 'lib/resource'

def policy
  $facts ||= JSON.parse( STDIN.read.to_s )
  $resources = {}
  yield

  output = {
      "Version" => "0",
      "Type" => "policy",
      "Parameters" => {
        "resources" => $resources,
        "name"      => "",
      }
    }
  puts JSON.dump( output )
end

def system(*keys)
  require 'lib/struct'
  if keys.length <= 0
    raise "you must pass parameters to system()"
  end
  Poppet::Struct.by_keys( $facts, ["Parameters"] + keys.map{|k| k.to_s })
end

def resource( type, name, params )
  $resources[name] = Poppet::Resource.new( {"Type" => type}, params ).data
  PolicyResource.new( name )
end

class PolicyResource
  def initialize( name )
    @name = name
  end

  def to_s
    @name.to_s
  end

  def after( res )
    $resources[@name]["Metadata"] ||= {}
    $resources[@name]["Metadata"]["after"] ||= []
    $resources[@name]["Metadata"]["after"] << res.to_s
  end

  def before( res )
    $resources[@name]["Metadata"] ||= {}
    $resources[@name]["Metadata"]["before"] ||= []
    $resources[@name]["Metadata"]["before"] << res.to_s
  end

  def nudge( res )
    $resources[@name]["Metadata"] ||= {}
    $resources[@name]["Metadata"]["nudge"] ||= []
    $resources[@name]["Metadata"]["nudge"] << res.to_s
  end

end
