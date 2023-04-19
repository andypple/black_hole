class ProcessEventJob < ApplicationJob
  queue_as :default

  def perform(event_id)
    # Do something later
  end
end
