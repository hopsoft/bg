require "bg/version"
require "bg/runner"

module Bg
  class << self
    attr_accessor :logfile

    def run(*args, &block)
      Runner.new(logfile: logfile).run(*args, &block)
    end

  end
end
