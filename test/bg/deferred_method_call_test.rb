require_relative "../test_helper"
require "active_job/test_helper"

class Bg::DeferredMethodCallJobTest < ::ActiveJob::TestCase

  test "enqueues with no args" do
    assert_enqueued_with job: ::Bg::DeferredMethodCallJob do
      obj = ::Bg::BackgroundableObject.new(:example)
      obj.eigen.send :include, ::Bg::Deferrable::Behavior
      obj.defer.update
    end
  end

  test "enqueues with simple args" do
    assert_enqueued_with job: ::Bg::DeferredMethodCallJob do
      obj = ::Bg::BackgroundableObject.new(:example)
      obj.eigen.send :include, ::Bg::Deferrable::Behavior
      obj.defer.update foo: true, bar: "baz"
    end
  end

  test "enqueues with globalid args" do
    assert_enqueued_with job: ::Bg::DeferredMethodCallJob do
      parent = ::Bg::BackgroundableObject.new(:parent)
      parent.eigen.send :include, ::Bg::Deferrable::Behavior
      parent.defer.update child: ::Bg::BackgroundableObject.new(:child)
    end
  end

  test "enqueues with complex args" do
    assert_enqueued_with job: ::Bg::DeferredMethodCallJob do
      parent = ::Bg::BackgroundableObject.new(:parent)
      parent.eigen.send :include, ::Bg::Deferrable::Behavior
      parent.defer.update children: [::Bg::BackgroundableObject.new(:child1), ::Bg::BackgroundableObject.new(:child2)],
        foo: { bar: [:baz, Date.new, Time.new, DateTime.new] }
    end
  end

  test "#perform_now properly invokes the method" do
    obj = ::Bg::BackgroundableObject.new(:example)
    assert ::Bg::DeferredMethodCallJob.perform_now(obj, :update)
  end

end
