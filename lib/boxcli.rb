require "pry"
require "pg"
require "redis"
require "json"
require "active_record"
require "boxcli/version"
require "boxcli/box"
require "boxcli/container"

module Boxcli
  class << self
    def start
      Pry.config.prompt = [ proc { ">> " }, proc { ">*" }]
      Pry.start self
    end

    def load_redis(port)
      $redis = Redis.new host: "127.0.0.1", port: port
    end

    def load_db(url)
      parsed_db_uri = URI.parse url
      ActiveRecord::Base.establish_connection(
        adapter:   "postgresql",
        encoding:  "utf8",
        reconnect: true,
        pool:      5,
        username:  parsed_db_uri.user,
        password:  parsed_db_uri.password,
        host:      parsed_db_uri.host,
        database:  parsed_db_uri.path.split("/")[-1],
        port:      parsed_db_uri.port
      )
    end
  end
end


if ENV['DATABASE_URL']
  Boxcli.load_db ENV['DATABASE_URL']
end

redis_port = ENV['REDIS_PORT'] || 65000
Boxcli.load_redis redis_port
