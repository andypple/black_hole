class StoreEventJob < ApplicationJob
  queue_as :default

  # Because I already add uniq index for `event_id` so when it's duplicated, it will raise ActiveRecord::InvalidRecord exception,
  # this job won't retry. Only one event record created and be processed and it's idempotemt right now.
  # The index for event_id has a price, it will slow donw the insert query.
  # Depends on the workload of insert events, if we remove the uniq index, we need to
  # introduce the event_state: [:read, :inprogress, :finish]
  # and in ProcessEventJob, we need to check the event state to make sure we don't
  # process the job twice.
  #
  # I'm considering retry on some database connection exception to avoid lossing event.
  def perform(event_params)
    event = Event.create!(event_params)
    ProcessEventJob.perform_later(event.id)
  end
end
