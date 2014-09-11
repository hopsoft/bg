require "micro_test"
require "pry"
require_relative "../lib/bg"

module Bg
  class RunnerTest < MicroTest::Test

    before do
      Bg.logger = Logger.new(File.expand_path("../../log/test.log", __FILE__))
    end

    test "foo" do
      Bg.run 1, 2, 3 do |a, b, c|
        sleep a
        sleep b
        sleep c
      end
    end

  end
end
