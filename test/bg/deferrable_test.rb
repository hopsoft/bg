require_relative "../test_helper"

class Bg::DeferrableTest < ::ActiveSupport::TestCase

  setup do
    @deferrable = ::Bg::Deferrable.new(::Bg::BackgroundableObject.new(:example))
  end

  test ".make_enqueable with Symbol" do
    value = ::Bg::Deferrable.make_enqueable(:foo)
    assert value == "foo"
  end

  test ".make_enqueable with Date" do
    date = ::Date.today
    value = ::Bg::Deferrable.make_enqueable(date)
    assert value == date.iso8601
  end

  test ".make_enqueable with Time" do
    time = ::Time.now
    value = ::Bg::Deferrable.make_enqueable(time)
    assert value == time.iso8601
  end

  test ".make_enqueable with DateTime" do
    date_time = ::DateTime.now
    value = ::Bg::Deferrable.make_enqueable(date_time)
    assert value == date_time.iso8601
  end

  test ".make_enqueable with Array" do
    date_time = ::DateTime.now
    list = [:foo, "bar", true, date_time]
    value = ::Bg::Deferrable.make_enqueable(list)
    assert value == ["foo", "bar", true, date_time.iso8601]
  end

  test ".make_enqueable with nested Array" do
    date_time = ::DateTime.now
    list = [:foo, "bar", true, date_time]
    list << list.dup
    value = ::Bg::Deferrable.make_enqueable(list)
    expected = ["foo", "bar", true, date_time.iso8601]
    expected << expected.dup
    assert value == expected
  end

  test ".make_enqueable with Hash" do
    date_time = ::DateTime.now
    hash = { a: :foo, b: "bar", c: true, d: date_time }
    value = ::Bg::Deferrable.make_enqueable(hash)
    assert value == { "a" => "foo", "b" => "bar", "c" => true, "d" => date_time.iso8601 }
  end

  test ".make_enqueable with nested Hash" do
    date_time = ::DateTime.now
    hash = { a: :foo, b: "bar", c: true, d: date_time }
    hash[:e] = hash.dup
    value = ::Bg::Deferrable.make_enqueable(hash)
    expected = { "a" => "foo", "b" => "bar", "c" => true, "d" => date_time.iso8601 }
    expected["e"] = expected.dup
    assert value == expected
  end

  test ".make_enqueable with complex Hash" do
    time = ::Time.now
    hash = { a: :foo, b: time, c: { a: :bar, b: time.dup }, d: [:baz, time.dup, {a: :wat, b: time.dup, c: [a: time.dup]}] }
    value = ::Bg::Deferrable.make_enqueable(hash)
    expected = {
      "a" => "foo",
      "b" => time.iso8601,
      "c" => { "a" => "bar", "b" => time.iso8601 },
      "d" => [ "baz", time.iso8601, { "a" => "wat", "b" => time.iso8601, "c" => [{"a" => time.iso8601}] } ]
    }
    assert value == expected
  end

end
