module Boxcli
  class Container < OpenStruct
    def container_name
      "#{name}-#{id}"
    end

    def mount_name
      base = container_name
      if uniqueId
        base += "-" + uniqueId.to_s
      end
      base
    end

    def verify_iptable
      p `sudo iptables -L -t nat | grep #{ip}`
      return $?.success?
    end

    def running?
      status == "running"
    end

    def stopped?
      status == "stopped"
    end

    def status
      # going to have format `state: STATUS`
      info = `sudo lxc-info -s -n #{mount_name}`
      info.each_line do |line|
        return line.split(":")[1].strip!.downcase!
      end
    end

    # persist the box value to redis
    def update_attribute(key, value)
      self[key] = value
      save
    end

    def save
      $redis.hset "aio:boxes", container_name, to_json
    end

    def to_json
      JSON.generate self.to_h
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
