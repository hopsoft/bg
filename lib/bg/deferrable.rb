require "globalid"
require_relative "deferred_method_call_job"

class Bg::Deferrable
  module Behavior
    # Enqueues the method call to be executed by a DeferredMethodCallJob background worker.
    def defer(queue: :default, wait: 0)
      Bg::Deferrable.new self, queue: queue, wait: wait
    end
  end

  def self.make_enqueable(value)
    case value
    when Hash then
      value.each.with_object({}) do |(key, val), memo|
        memo[key.to_s] = make_enqueable(val)
      end
    when Array then
      value.map { |val| make_enqueable val }
    when Symbol then
      value.to_s
    when Date, Time, DateTime then
      value.respond_to?(:iso8601) ? value.iso8601 : value.to_s
    else
      value
    end
  end

  def initialize(object, queue: :default, wait: 0)
    raise ArgumentError unless object.is_a?(GlobalID::Identification)
    @object = object
    @queue  = queue || :default
    @wait   = wait.to_i
  end

  def method_missing(name, *args)
    if @object.respond_to? name
      raise ArgumentError.new("blocks are not supported") if block_given?
      begin
        queue_args = { queue: @queue }
        queue_args[:wait] = @wait if @wait > 0
        job = Bg::DeferredMethodCallJob.set(**queue_args).perform_later @object, name.to_s, *self.class.make_enqueable(args)
      rescue StandardError => e
        raise ArgumentError.new("Failed to background method call! <#{@object.class.name}##{name}> #{e.message}")
      ensure
        return job
      end
    end
    super
  end

  def respond_to?(name)
    return true if @object.respond_to? name
    super
  end
end
