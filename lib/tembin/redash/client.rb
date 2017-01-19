require 'faraday'

module Tembin::Redash
  class Client
    class RequestNotSucceedError < StandardError; end

    def self.current
      Thread.current[:__tembin__redash_client__] ||= new(Tembin::Redash.config['api_key'])
    end

    def initialize(api_key)
      @api_key = api_key
    end

    def get(path, params: {})
      response = connection.get(path, { api_key: @api_key }.merge(params))
      raise RequestNotSucceedError, response.body if !response.success?
      response
    end

    def post(path, body: {}, params: {})
      response = connection.post do |req|
        req.url(path)
        req.params = params.merge(api_key: @api_key)
        req.body = body.to_json
        req
      end

      raise RequestNotSucceedError, response.body if !response.success?

      response
    end

    def delete(path, params: {})
      response = connection.delete(path, { api_key: @api_key }.merge(params))
      raise RequestNotSucceedError, response.body if !response.success?
      response
    end

    private

    def connection
      @connection ||= Faraday.new(url: Tembin::Redash.config['host'])
    end
  end
end
