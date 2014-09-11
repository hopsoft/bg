require "thread"
require "drb"
require "logger"

module Bg
  class DrbRunner
    attr_reader :logger

    def initialize(logfile: logfile)
      @logger = Logger.new(logfile || "/dev/null")
    end

    def ready?
      true
    end

    def run(proc: nil, args: [])
      Thread.new do
        begin
          sleep 0
          method = "define_method :run #{proc}"
          runner = Class.new { eval method }
          logger.info "Start exec: #{method}"
          runner.new.run(*Marshal.load(args))
          logger.info "Finish exec: #{method}"
        rescue Exception => e
          logger.error "Failed exec: #{method}\n#{e}"
        ensure
          DRb.stop_service rescue nil
          Process.exit
        end
      end
    end

  end
end
