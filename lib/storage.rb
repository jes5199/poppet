require 'fileutils'
require 'lib/timestamp'
module Poppet
  module Storage
    def self.file(name, &blk)
      FileUtils.mkdir_p( File.dirname(name) )
      File.open(name, 'w', &blk)
    end

    def self.timestamp_file(dir, &blk)
      self.file(File.join(dir, Poppet::Timestamp.now), &blk)
    end
  end
end
