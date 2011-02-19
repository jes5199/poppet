require 'net/http'
require 'uri'
module Poppet
  module HTTP
    def self.post(uri, data)
      uri = URI.parse(uri)
      Net::HTTP.start(uri.host, uri.port) do |http|
        request = Net::HTTP::Post.new(uri.request_uri)
        request.body = data
        request["Content-Type"] = "application/json"
        http.request(request) do |response|
          response.value #raises error if not 2xx
        end.body
      end
    end

    def self.get(uri)
      uri = URI.parse(uri)
      Net::HTTP.start(uri.host, uri.port) do |http|
        request = Net::HTTP::Get.new(uri.request_uri)
        http.request(request) do |response|
          response.value #raises error if not 2xx
        end.body
      end
    end
  end
end
