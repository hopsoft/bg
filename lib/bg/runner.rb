require "method_source"
require "thread"
require "drb"
require "logger"
require "bg/drb_runner"

module Bg
  class Runner
    attr_reader :logger, :drb_uri, :drb_pid, :drb_runner

    def initialize(logger: nil)
      @logger = logger
      @drb_uri = "druby://127.0.0.1:#{random_port}"
    end

    def run(*args, &block)
      DRb.start_service
      start_drb_runner
      drb_runner.run(
        proc: proc_string(block),
        args: Marshal.dump(args)
      )
      DRb.stop_service
    end

    private

    def proc_string(proc)
      code = proc.source
      index = code.index(/\{|do/)
      code[index..-1].strip
    end

    def start_drb_runner
      return if drb_runner
      @drb_pid = fork do
        DRb.start_service drb_uri, DrbRunner.new(logger: logger)
        DRb.thread.join
      end
      Process.detach drb_pid
      @drb_runner = DRbObject.new_with_uri(drb_uri)
      sleep 0.001 while !drb_runner_ready?
      drb_runner
    end

    def drb_runner_ready?
      begin
        drb_runner.ready?
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
