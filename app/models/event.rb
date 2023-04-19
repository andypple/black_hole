class Event < ApplicationRecord
  ALLOWED_EVENTS = %w[create_bill update_bill delete_bill].freeze

  validates :event_code, :event_id, presence: true
  validates :event_id, uniqueness: true
  validates :event_code,
            inclusion: { in: ALLOWED_EVENTS, message: I18n.t('events.errors.error_code', value: '%<value>s') }
end
