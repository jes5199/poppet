#!/usr/bin/ruby

require 'rubygems'
require 'json'
require 'lib/implementor/subimp'

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
  end
end

subimp = PackageImp.new( desired_json )

imp_file = File.join(settings["imp"], res.data["Type"], subimplementor + ".rb") # TODO: smarter executable finding, extract into lib
imp = Poppet::Implementor.new( imp_file )
imp.execute( [command, desired_json] )
