module Bg
  class DrbRunner

    def initialize(logger: logger)
      @logger = logger || Logger.new("/dev/null")
    end

    def ready?
      true
    end

    def run(proc: nil, args: [], logger: nil)
      Thread.new do
        begin
          sleep 0
          method = "define_method :run #{proc_string}"
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
