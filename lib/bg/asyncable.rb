require "active_record"
require "concurrent"

module Bg
  class Asyncable
    class Wrapper
      include ::Concurrent::Async

      def initialize(object, wait: 0)
        # IMPORTANT: call super without any arguments
        # https://ruby-concurrency.github.io/concurrent-ruby/Concurrent/Async.html
        super()
        @object = object
        @wait = wait.to_f
      end

      def invoke_method(name, *args)
        sleep @wait if @wait > 0
        base = self.is_a?(::ActiveRecord::Base) ? self.class : ::ActiveRecord::Base
        base.connection_pool.with_connection do
          @object.send name, *args
        end
      end
    end

    module Behavior
      def async(wait: 0)
        ::Bg::Asyncable.new(self, wait: wait.to_f)
      end
    end

    def initialize(object, wait: 0)
      @object = object
      @wait = wait.to_f
    end

    def method_missing(name, *args)
      if @object.respond_to? name
        raise ::ArgumentError.new("blocks are not supported") if block_given?
        begin
          wrapped = ::Bg::Asyncable::Wrapper.new(@object, wait: @wait)
          wrapped.async.invoke_method name, *args
        rescue ::StandardError => e
          raise ::ArgumentError.new("Failed to execute method asynchronously! <#{@object.class.name}##{name}> #{e.message}")
        ensure
          return
        end
      end
      super
    end

    def respond_to?(name)
      return true if @object.respond_to? name
      super
    end
  end
end
