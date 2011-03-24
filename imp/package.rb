#!/usr/bin/ruby

require 'rubygems'
require 'json'
require 'lib/implementor/subimp'
require 'lib/settings'

settings = Poppet::Settings.new

command, desired_json = JSON.parse( STDIN.read )

class PackageImp < Poppet::Implementor::Subimp
  def subimplementor
    subimplementor = resource["implementor"]

    if ! subimplementor
      subimplementor = case resource["package_type"]
      when "deb"
        "apt"
      when "gem"
        "gem"
      end
    end

    if ! subimplementor
      raise "You must supply a package_type"
    end

    return subimplementor
  end
end

subimp = PackageImp.new( desired_json, {"imp" => settings["imp"]} )
print subimp.execute( [command, desired_json] )
