module Aliexpress
  class Cache

    # 生成 redis key
    def self.generate_key(*key)
      "aliexpress_#{key.map { |x| x.respond_to?(:to_a) ? x.to_a : x}.flatten.join('_')}"
    end

    # 获取对应 key 的值 - 想办法从写这个函数
    def self.fetch(key, time = 12.hour)
      puts "###### cache-key #######  #{key} #######"

      Aliexpress.redis.fetch key, expires_in: time do
        yield
      end
    end
  end
end
