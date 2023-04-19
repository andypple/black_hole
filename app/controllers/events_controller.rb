class EventsController < ApplicationController
  before_action :verify_sinagture!

  def create
    StoreEventJob.perform_later(event_params.to_h)
    render_success
  end

  private

  def verify_sinagture!
    webhook_secret_key = Rails.application.credentials[:webhook_secret_key]
    header_key = request.headers['HTTP-X-WEBHOOK-SECRET-KEY']
    return if header_key.present? && Rack::Utils.secure_compare(webhook_secret_key, header_key)

    render_error(I18n.t('events.errors.webhook_key'))
  end

  def render_success
    render json: { message: I18n.t('events.acknowledge'), status: :ok }
  end

  def render_error(error)
    render json: { error: error }, status: :unprocessable_entity
  end

  def event_params
    @event_params ||= params.permit(:customer_id, :event_code, :event_id, :timestamp, properties: {})
  end
end
