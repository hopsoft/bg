module Bg
  class DeferredMethodCallJob < ApplicationJob
    queue_as :default

    def perform(object, method, *args)
      object.send method, *args
    end
  end
end
