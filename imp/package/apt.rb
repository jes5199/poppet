#!/usr/bin/ruby
require 'lib/implementor/dsl'
implementor do |desired|
  if ! desired["name"]
    raise "A package must be identified by name"
  end

  self.reader_class = class PackageReader < Poppet::Implementor::Reader
    readers :name, :versions, :status, :package_type

    def name
      desired["name"]
    end

    def package_type
      "deb"
    end

    def dpkg_query
      @dpkg_query ||= ( x( "dpkg-query -s #{e name}" ).split(/\n/) rescue [] )
    end

    def versions
      dpkg_query.grep(/^Version: (.*)/)
      [ $1.strip ]
    end

    def status
      dpkg_query.grep(/^Status: \S* \S* (\S*)/)
      case $1
      when "installed"
        "installed"
      when "config-files"
        "configured"
      when "not-installed"
        "absent"
      end
    end

    self
  end

  self.checker_class = class PackageChecker < Poppet::Implementor::Checker
    checkers :name, :versions, :status, :package_type

    def versions(actual_value, desired_value)
      desired_value.all? do |des|
        actual_value.include?(des)
      end
    end

    def status(actual_value, desired_value)
      return true if desired_value == "configured" && actual_value == "absent" # because we don't actually want to install and uninstall just to drop config files
      desired_value == actual_value
    end

    self
  end

  self.writer_class = class PackageWriter < Poppet::Implementor::Writer
    actions :install, :nudge, :remove, :purge

    def apt_get(args)
      x( "export DEBIAN_FRONTEND=noninteractive ; apt-get #{args}" )
    end

    def apt_get_install(packages)
      apt_get( "install -y #{packages}" )
    end

    def install( extra_args = nil )
      versions = ( desired["vesions"] || [] )
      raise "apt can only install one version at a time" if versions.length > 1

      version = versions.first
      if version == "latest" or !version
        name = e desired["name"]
      else
        name = "#{e desired["name"]}=#{e version}"
      end
      apt_get_install( "#{name} #{extra_args}" )
      actual.merge({
        "status"   => "installed",
        "versions" => [ version || "latest" ] # TODO: actually resolve "latest" ?
      })
    end

    def nudge
      install("--reinstall")
    end

    def remove
      apt_get( "remove #{ e desired["name"] }" )

      actual.merge({
        "status"   => "configured",
        "versions" => nil
      })
    end

    def purge
      apt_get( "purge #{ e desired["name"] }" )

      actual.merge({
        "status"   => "absent",
        "versions" => nil
      })
    end

    self
  end
end
