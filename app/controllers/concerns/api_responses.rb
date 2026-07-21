# frozen_string_literal: true

# Shared response helpers included in ApplicationController.
#
# Error envelope shape: { errors: [{ code:, message: }] }
# Success envelope shape: { data: ... } with optional { meta: ... }
# Contract is documented in ai/api-contract.md.
module ApiResponses
  extend ActiveSupport::Concern

  def render_success(resource, status: :ok, meta: nil)
    payload = { data: serialized(resource) }
    payload[:meta] = meta unless meta.nil?
    render json: payload, status: status
  end

  # meta is omitted when nil or empty — Phase 1 pagination will pass meta: { pagination: { ... } }
  def render_collection(resources, meta: nil)
    payload = { data: serialized(resources) }
    payload[:meta] = meta if meta.present?
    render json: payload
  end

  # Use for single-error responses (auth, ownership, not_found, etc.).
  # For field-level validation errors use render_validation_errors.
  def render_error(code:, message:, status:)
    render json: { errors: [{ code: code, message: message }] }, status: status
  end

  # Maps ActiveModel errors to per-field error objects in the errors array.
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

  # Derives error code from the message text produced by ImageAttachable.
  # TODO: replace with a structured error object from ImageAttachable in Phase 1
  #       so this doesn't have to parse human-readable strings.
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
