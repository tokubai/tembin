require 'json'
require 'diffy'

module Tembin::Redash
  class Query
    def self.all
      response = Tembin::Redash::Client.current.get('/api/queries')
      raise RequestNotSucceedError, response.body if !response.success?
      JSON.parse(response.body).map { |j| self.new(j) }
    end

    def self.created_by_me
      all.select { |q| q.author_email == Tembin::Redash.config['authorized_user_email'] }
    end

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
