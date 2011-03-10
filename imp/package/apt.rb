#!/usr/bin/ruby
require 'lib/implementor/dsl'
implementor do |desired|
  if ! desired["name"]
    raise "A package must be identified by name"
  end

  class PackageReader < reader_class
    readers :name, :versions, :status, :dpkg_query

    def name
      desired["name"]
    end

    def dpkg_query
      x( "dpkg-query #{e name}" ).split(/\n/) rescue []
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
  end

  class PackageChecker < checker_class
    checkers :name, :versions, :status

    def versions(actual_value, desired_value)
      desired_value.all? do |des|
        actual_value.include?(des)
      end
    end

    def status(actual_value, desired_value)
      return true if desired_value == "configured" && actual_value == "absent" # because we don't actually want to install and uninstall just to drop config files
      desired_value == actual_value
    end
  end

  class PackageWriter < writer_class
    actions :install, :nudge, :remove, :purge

    def apt_get(args)
      x( "export DEBIAN_FRONTEND=noninteractive ; apt-get #{args}" )
    end

    def apt_get_install(packages)
      apt_get( "install -y #{packages}" )
    end

    def install( extra_args = nil )
      raise "apt can only install one version at a time" if desired["vesions"].length > 1

      version = desired["versions"].first
      if version == "latest"
        name = e desired["name"]
      else
        name = "#{e desired["name"]}=#{e version}"
      end
      apt_get_install( "#{name} #{extra_args}" )
      actual.merge({
        "state"    => "installed",
        "versions" => [ version ] # TODO: something smarter re:latest ?
      })
    end

    def nudge
      install("--reinstall")
    end

    def remove
      apt_get( "remove #{ e desired["name"] }" )

      actual.merge({
        "state"    => "configured",
        "versions" => nil
      })
    end

    def purge
      apt_get( "purge #{ e desired["name"] }" )

      actual.merge({
        "state"    => "absent",
        "versions" => nil
      })
    end

  end
end
