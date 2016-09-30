require "active_record"
require "concurrent"
require "globalid"

module Bg
  class Asyncable
    class Wrapper
      include ::Concurrent::Async
      attr_reader :global_id, :delay

      def initialize(global_id, delay: 0)
        # IMPORTANT: call super without any arguments
        # https://ruby-concurrency.github.io/concurrent-ruby/Concurrent/Async.html
        super()
        @global_id = global_id
        @delay = delay.to_f
      end

      def invoke_method(name, *args)
        sleep delay if delay > 0
        ::ActiveRecord::Base.connection_pool.with_connection do
          global_id.find.send name, *args
        end
      end
    end

    module Behavior
      def async(delay: 0)
        ::Bg::Asyncable.new(self, delay: delay.to_f)
      end
    end

    attr_reader :object, :delay

    def initialize(object, delay: 0)
      raise ::ArgumentError unless object.is_a?(::GlobalID::Identification)
      @object = object
      @delay = delay.to_f
    end

    def method_missing(name, *args)
      if object.respond_to? name
        raise ::ArgumentError.new("blocks are not supported") if block_given?
        begin
          wrapped = ::Bg::Asyncable::Wrapper.new(object.to_global_id, delay: delay)
          wrapped.async.invoke_method name, *args
        rescue ::StandardError => e
          raise ::ArgumentError.new("Failed to execute method asynchronously! <#{object.class.name}##{name}> #{e.message}")
        ensure
          return
        end
      end
      super
    end

    def respond_to?(name)
      return true if object.respond_to? name
      super
    end
  end
end
