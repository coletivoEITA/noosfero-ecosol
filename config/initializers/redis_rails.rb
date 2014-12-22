# patch to do not crash on redis backend errors
# https://github.com/redis-store/redis-rails/issues/14

module ActiveSupport
  module Cache
    class RedisStore < Store

      %w[increment decrement clear read_entry write_entry delete_entry].each do |method|
        define_method "#{method}_with_rescue" do |*args, &block|
          begin
            self.send "#{method}_without_rescue", *args, &block
          rescue
            nil
          end
        end
        alias_method_chain method, :rescue
      end
    end
  end
end
