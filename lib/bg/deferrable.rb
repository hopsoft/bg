module Bg
  class Deferrable
    module Behavior
      # Enqueues the method call to be executed by a DeferredMethodCallJob background worker.
      def defer(queue: :default, wait: 0)
        ::Deferrable.new self, queue: queue, wait: wait
      end
    end

    attr_reader :object, :queue, :wait

    def initialize(object, queue: :default, wait: 0)
      raise ::ArgumentError unless object.is_a?(::GlobalID::Identification)
      @object = object
      @queue  = queue || :default
      @wait   = wait.to_i
    end

    def method_missing(name, *args)
      if object.respond_to? name
        raise ::ArgumentError.new("blocks are not supported") if block_given?
        begin
          if wait > 0
            job = ::DeferredMethodCallJob.set(queue: queue, wait: wait).perform_later object, name.to_s, *args
          else
            job = ::DeferredMethodCallJob.set(queue: queue).perform_later object, name.to_s, *args
          end
        rescue ::StandardError => e
          raise ::ArgumentError.new("Failed to background method call! <#{object.class.name}##{name}> #{e.message}")
        ensure
          return job
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
