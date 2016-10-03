require "coveralls"
Coveralls.wear!
require_relative "../lib/bg"
require_relative "backgroundable_object"
require "minitest/autorun"
require "purdytest"
#require "pry"
#require "pry-nav"
#require "pry-stack_explorer"

::ActiveSupport::TestCase.test_order = :random
::GlobalID.app = "test"
::ActiveRecord::Base = Class.new do
  def connection_pool
    Class.new do
      def with_connection
        yield
      end
    end
  end
end
