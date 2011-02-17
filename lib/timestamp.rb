module Poppet
  module Timestamp
    def self.now
      Time.now.strftime("%F_%T")
    end
  end
end
