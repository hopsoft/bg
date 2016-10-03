require_relative "../test_helper"

class Bg::AsyncableTest < ::ActiveSupport::TestCase

  test "slow io bound method invocations run in parallel" do
    obj = ::Bg::BackgroundableObject.new(:example)
    obj.eigen.send :include, ::Bg::Asyncable::Behavior
    start = Time.now
    10.times { obj.async.wait 1 }
    assert (Time.now - start) <= 1.1
  end

end
