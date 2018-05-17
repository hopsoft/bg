require "active_job"

class Bg::DeferredMethodCallJob < ActiveJob::Base
  queue_as :default

  def perform(object, method, *args)
    object.send method, *args
  end
end
