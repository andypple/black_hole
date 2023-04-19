FactoryBot.define do
  factory :event do
    customer_id { SecureRandom.hex(5) }
    event_code { 'create_bill' }
    event_id { SecureRandom.hex(5) }
  end
end
