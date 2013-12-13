module Boxcli
  class Container < OpenStruct
    def container_name
      name + "-" + id
    end

    def running?
      status == "running"
    end

    def stopped?
      status == "stopped"
    end

    def status
      info = `sudo lxc-info -n #{container_name}`
      info.each_line do |line|
        return line.split(":")[1].strip!.downcase! if line.start_with?("state:")
      end
    end

    def self.first
      all[0]
    end

    def self.find(name)
      box_json = $redis.hget "aio:boxes", name
      return unless box_json
      self.parse box_json
    end

    def self.all
      box_json = $redis.hgetall "aio:boxes"
      return unless box_json
      box_json.map { |k, v| self.parse(v) }
    end

    def self.parse(json)
      self.new JSON.parse(json)
    end
  end
end
