require 'dalli'
require 'memcachier'

module Sprockets
  module Cache
    # A simple Memcache cache store.
    #
    # environment.cache = Sprockets::Cache::MemcacheStore.new
    #
    class MemcacheStore

      def initialize(key_prefix = 'sprockets')
        @memcache = Dalli::Client.new
        @key_prefix = key_prefix

        Dalli.logger = Logger.new('/dev/null')
      end

      # Lookup value in cache
      def [](key)
        data = @memcache.get path_for(key)
        Marshal.load data if data
      end

      # Save value to cache
      def []=(key, value)
        @memcache.set path_for(key), Marshal.dump(value)
        value
      end

      private

      def path_for(key)
        "#{@key_prefix}:#{key}"
      end
    end
  end
end
