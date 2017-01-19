module Tembin::Redash
  def self.config=(value)
    @config = value
  end

  def self.config
    @config ||= {
      api_key:               nil,
      host:                  nil,
    }
  end
end

require 'tembin/redash/client'
require 'tembin/redash/query'
