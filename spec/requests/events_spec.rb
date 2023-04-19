require 'rails_helper'

RSpec.describe "/events", type: :request do
  describe "POST /create" do
    before do
      allow(Rails.application).to receive(:credentials).and_return(OpenStruct.new(webhook_secret_key: 'webhook_secret_key'))
    end

    let(:valid_headers) { { 'HTTP-X-WEBHOOK-SECRET-KEY': 'webhook_secret_key' } }

    context "with valid parameters" do
      let(:event_timestamp) { '2022-05-05 07:05:29 UTC' }
      let(:valid_attributes) {
        FactoryBot.attributes_for(:event, timestamp: event_timestamp, properties: { 'extra' => 1 })
      }

      it "creates a new Event" do
        post events_url, params: valid_attributes, headers: valid_headers, as: :json

        allow(ProcessEventJob).to receive(:perform_later)
        perform_enqueued_jobs

        event = Event.last
        expect(event.customer_id).to eq valid_attributes[:customer_id]
        expect(event.event_code).to eq valid_attributes[:event_code]
        expect(event.event_id).to eq valid_attributes[:event_id]
        expect(event.timestamp).to be_within(1.second).of Time.zone.parse(valid_attributes[:timestamp])
        expect(ProcessEventJob).to have_received(:perform_later).with(event.id)
      end
    end

    context 'without valid header key' do
      it "renders header key error" do
        post events_url, as: :json
        expect(response).to have_http_status(:unprocessable_entity)
        expect(response.content_type).to match(a_string_including("application/json"))
        data = JSON.parse(response.body)
        expect(data).to eq({ 'error' => I18n.t('events.errors.webhook_key') })
      end
    end
  end
end
