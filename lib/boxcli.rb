require "pry"
require "pg"
require "redis"
require "json"
require "active_record"
require "boxcli/version"
require "boxcli/container"

if ENV['DATABASE_URL']
  parsed_db_uri = URI.parse(ENV['DATABASE_URL'])
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
  require "boxcli/box"
end

redis_port = ENV['REDIS_PORT'] || 65000
$redis = Redis.new(host: "127.0.0.1", port: redis_port)

module Boxcli
  class << self
    def start
      Pry.config.prompt = [ proc { ">> " }, proc { ">*" }]
      Pry.start self
    end
  end
end
