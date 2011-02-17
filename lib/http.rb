require 'net/http'
require 'uri'
module Poppet
  module HTTP
    def self.post(uri, data)
      uri = URI.parse(uri)
      http = Net::HTTP.new(uri.host, uri.port)
      request = Net::HTTP::Post.new(uri.request_uri)
      request.body = data
      request["Content-Type"] = "application/json"
      http.request(request).tap do |response|
        response.value #raises error if not 2xx
      end.body
    end
  end
end
