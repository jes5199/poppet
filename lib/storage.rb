require 'fileutils'
require 'lib/timestamp'
module Poppet
  module Storage
    def file(name, &blk)
      FileUtils.mkdir_p( File.dirname(name) )
      File.open(File.join(dir, name), &blk)
    end

    def self.timestamp_file(dir, &blk)
      self.file(File.join(dir, Poppet::Timestamp.now), &blk)
    end
  end
end
