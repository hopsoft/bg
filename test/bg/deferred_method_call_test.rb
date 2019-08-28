require_relative "../test_helper"

class Bg::DeferredMethodCallJobTest < PryTest::Test
  test "enqueues with no args" do
    obj = Bg::BackgroundableObject.new(:example)
    obj.eigen.send :include, Bg::Deferrable::Behavior
    object, method, args = obj.defer.update
    assert object == obj
    assert method == "update"
    assert args == []
  end

  test "enqueues with simple args" do
    obj = Bg::BackgroundableObject.new(:example)
    obj.eigen.send :include, Bg::Deferrable::Behavior
    object, method, args = obj.defer.update(foo: true, bar: "baz")
    assert object == obj
    assert method == "update"
    assert args == [{"foo" => true, "bar" => "baz"}]
  end

  test "enqueues with globalid args" do
    parent = Bg::BackgroundableObject.new(:parent)
    child = Bg::BackgroundableObject.new(:child)
    parent.eigen.send :include, Bg::Deferrable::Behavior
    object, method, args = parent.defer.update(child: child)
    assert object == parent
    assert method == "update"
    assert args == [{"child"=>"gid://test/Bg::BackgroundableObject/child"}]
  end

  test "enqueues with complex args" do
    parent = Bg::BackgroundableObject.new(:parent)
    parent.eigen.send :include, Bg::Deferrable::Behavior
    a = Date.new
    b = Time.new
    c = DateTime.new
    object, method, args = parent.defer.update(
      children: [Bg::BackgroundableObject.new(:child1), Bg::BackgroundableObject.new(:child2)],
      foo: { bar: [:baz, a, b, c] }
    )
    assert object == parent
    assert method == "update"
    assert args == [{
      "children"=>["gid://test/Bg::BackgroundableObject/child1", "gid://test/Bg::BackgroundableObject/child2"],
      "foo"=>{"bar"=>["baz", a.iso8601, b.iso8601, c.iso8601]}
    }]
  end
end
