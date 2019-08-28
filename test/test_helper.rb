require "pry-test"
require "coveralls"
Coveralls.wear!
require_relative "../lib/bg"
require_relative "backgroundable_object"

GlobalID.app = "test"
ActiveRecord::Base = Class.new do
  def connection_pool
    Class.new do
      def with_connection
        yield
      end
    end
  end
end

class Bg::DeferredMethodCallJob
  class << self
    def set(**args)
      self
    end

    def perform_later(object, method, *args)
      [object, method, args.map { |arg| argument arg }]
    end

    private

    def argument(arg)
      case arg
      when Array then arg.map { |a| argument a }
      when Hash then arg.each_with_object({}) { |(key, val), memo| memo[key] = argument(val) }
      else arg.respond_to?(:to_gid) ? arg.to_gid.to_s : arg
      end
    end
  end
end
