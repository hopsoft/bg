require "thread"
require "drb"
require "logger"

module Bg
  class DrbRunner
    attr_reader :logger

    def initialize(logfile: logfile)
      @logger = Logger.new(logfile || "/dev/null")
      #@logger = Logger.new(File.expand_path("../../../log/test.log", __FILE__))
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
          DRb.stop_service
          Process.exit 0
        rescue Exception => e
          logger.info "Failed exec: #{method}\n#{e}"
          DRb.stop_service rescue nil
          Process.exit 1
        end
      end
    end

  end
end
