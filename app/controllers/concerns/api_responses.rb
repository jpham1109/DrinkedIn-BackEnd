# frozen_string_literal: true

module ApiResponses
  extend ActiveSupport::Concern

  def render_success(resource, status: :ok, meta: nil)
    payload = { data: serialized(resource) }
    payload[:meta] = meta unless meta.nil?
    render json: payload, status: status
  end

  def render_collection(resources, meta: {})
    render json: { data: serialized(resources), meta: meta }
  end

  def render_error(code:, message:, status:, field: nil)
    error = { code: code, message: message }
    error[:field] = field if field
    render json: { errors: [error] }, status: status
  end

  def render_validation_errors(record)
    errors = record.errors.map do |error|
      { code: 'validation_failed', field: error.attribute.to_s, message: error.full_message }
    end
    render json: { errors: errors }, status: :unprocessable_entity
  end

  def render_upload_errors(messages)
    errors = messages.map { |msg| { code: upload_error_code(msg), message: msg } }
    render json: { errors: errors }, status: :unprocessable_entity
  end

  private

  def serialized(resource)
    if resource.is_a?(ActiveRecord::Base) ||
       resource.is_a?(ActiveRecord::Relation) ||
       (resource.is_a?(Array) && resource.first.is_a?(ActiveRecord::Base))
      ActiveModelSerializers::SerializableResource.new(resource).as_json
    else
      resource
    end
  end

  def upload_error_code(message)
    if message.match?(/JPEG|PNG|WebP/i)
      'upload_invalid_type'
    elsif message.match?(/5MB/i)
      'upload_too_large'
    else
      'upload_invalid'
    end
  end
end
