#!/usr/bin/ruby

require 'rubygems'
require 'json'
require 'lib/implementor/dispatcher'
require 'lib/settings'

settings = Poppet::Settings.new

command, desired_json = JSON.parse( STDIN.read )

class PackageImp < Poppet::Implementor::Dispatcher
  def subimplementor
    subimplementor = resource["implementor"]

    subimplementor ||= case resource["package_type"]
    when "deb"
      "apt"
    when "gem"
      "gem"
    end

    subimplementor or raise "You must supply a package_type"

    return subimplementor
  end
end

subimp = PackageImp.new( desired_json, {"imp" => settings["imp"]} )
print subimp.execute( [command, desired_json] )
