require "active_job"

module Bg
  class DeferredMethodCallJob < ::ActiveJob::Base
    queue_as :default

    def perform(object, method, *args)
      object.send method, *args
    end
  end
end
