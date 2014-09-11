require "bg/version"
require "bg/runner"

module Bg
  class << self
    attr_accessor :logger

    def run(*args, &block)
      Runner.new(logger: logger).run_and_forget(*args, &block)
    end
  end
end
