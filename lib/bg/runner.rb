require "method_source"
require "thread"
require "monitor"
require "drb"
require "logger"

module Bg
  class Runner
    include MonitorMixin
    attr_reader :logger, :drb_uri, :drb_pid, :drb_instance

    def initialize(logger: nil)
      binding.pry
      @logger = logger || Logger.new("/dev/null")
      @drb_uri = "druby://127.0.0.1:#{random_port}"
    end

    def run_and_forget(*args, &block)
      DRb.start_service
      start_drb_instance
      drb_instance.drb_run_and_forget(proc_string(block), Marshal.dump(args))
      DRb.stop_service
    end

    def drb_run_and_forget(proc_string, args)
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

    def ready?
      true
    end

    private

    def proc_string(proc)
      code = proc.source
      index = code.index(/\{|do/)
      code[index..-1].strip
    end

    def start_drb_instance
      return if drb_instance
      @drb_pid = fork do
        DRb.start_service drb_uri, self
        DRb.thread.join
      end
      Process.detach drb_pid
      @drb_instance = DRbObject.new_with_uri(drb_uri)
      sleep 0.001 while !drb_instance_ready?
    end

    def drb_instance_ready?
      begin
        drb_instance.ready?
      rescue DRb::DRbConnError
        false
      end
    end

    def random_port
     socket = Socket.new(:INET, :STREAM, 0)
     socket.bind(Addrinfo.tcp("127.0.0.1", 0))
     port = socket.local_address.ip_port
     socket.close
     port
    end

  end
end
