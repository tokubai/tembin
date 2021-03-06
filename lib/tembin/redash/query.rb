require 'json'
require 'diffy'

module Tembin::Redash
  class Query
    class RequestNotSucceedError < StandardError; end

    def self.all
      response = Tembin::Redash::Client.current.get('/api/queries')
      raise RequestNotSucceedError, response.body if !response.success?
      JSON.parse(response.body)['results'].map { |j| self.new(j) }
    end

    PAGE_OPTION = {
      page: 1,
      page_size: 5,
    }.freeze
    def self.created_by_me(fetch_all_page: true)
      if !fetch_all_page
        return request_my_query(PAGE_OPTION)['results'].map { |j| self.new(j) }
      end
      responses = []
      response = request_my_query(PAGE_OPTION)
      responses << response
      while response['count'] > (response['page'] * response['page_size'])
        response = request_my_query(page: response['page'] + 1, page_size: response['page_size'])
        responses << response
      end
      responses.flat_map { |r| r['results'].map { |j| new(j) } }
    end

    def self.request_my_query(page_option = {})
      response = Tembin::Redash::Client.current.get('/api/queries/my', params: page_option)
      if !response.success?
        raise RequestNotSucceedError, response.body
      end
      JSON.parse(response.body)
    end
    private_class_method :request_my_query

    INITIAL_DATA_SOURCE_ID = 1
    def self.create(name, sql)
      Tembin::Redash::Client.current.post("/api/queries", body: { name: name, query: sql, data_source_id: INITIAL_DATA_SOURCE_ID })
    end

    def initialize(attributes)
      @attributes = attributes
    end

    def id
      @attributes['id']
    end

    def name
      @attributes['name']
    end

    def author_email
      @attributes['user'] && @attributes['user']['email']
    end

    def sql
      @attributes['query']
    end

    def filename
      "#{@attributes['id']}_#{@attributes['name'].gsub(/(\/|-|\s)/, '_')}"
    end

    def changed?(query)
      Diffy::Diff.new(sql, query).to_s.length != 0
    end

    def update!(query)
      Tembin::Redash::Client.current.post("/api/queries/#{id}", body: { query: query })
    end

    def delete!
      Tembin::Redash::Client.current.delete("/api/queries/#{id}")
    end
  end
end
