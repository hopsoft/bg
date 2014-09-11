require "bg/version"
require "bg/runner"

module Bg
  class << self
    attr_accessor :logger

    def run(*args, &block)
      Runner.new(logger: logger).run(*args, &block)
    end

  end
end
