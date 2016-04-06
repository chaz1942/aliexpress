module Aliexpress
  class Cache

    mattr_accessor :redis
    self.redis = Aliexpress.redis # 设置类对象 redis

    # 获取特定值的 key
    def self.get(key)
      redis.get key
    end

    # 生成 redis key
    def self.generate_key(*key)
      "aliexpress_#{key.map { |x| x.respond_to?(:to_a) ? x.to_a : x}.flatten.join('_')}"
    end

    # fetch 获取 redis 中的 key，若 key 存在则返回，反之，则调用块
    #
    # @param [string] key - 存储在 redis 中的健
    # @param [Time] time - key 的过期，默认为空
    def self.fetch(key, time = nil)
      puts "###### cache-key #######  #{key} #######"

      value = redis.get key

      unless value.nil?
        return Marshal.load(value)
      else
        value = yield

        redis.multi do
          redis.set key, Marshal.dump(value)
          redis.expireat key, time if time.present?
        end

        value
      end
    end
  end
end
