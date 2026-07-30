# frozen_string_literal: true

# Pre-warms the standard image variant (see ImageAttachable#image_variant) in
# the background right after an upload, so the first browser request for it
# doesn't pay the cost of synchronous processing inside
# ActiveStorage::Representations::RedirectController. If this job hasn't run
# yet (or fails permanently), that on-demand path still processes lazily on
# first request — this job is a performance optimization, not a dependency.
class ProcessImageVariantJob < ApplicationJob
  queue_as :default

  retry_on StandardError, wait: :polynomially_longer, attempts: 5 do |job, error|
    record = job.arguments.first
    Rails.logger.error(
      "ProcessImageVariantJob failed permanently for #{record.class}##{record.id}: #{error.message}"
    )
  end

  def perform(record)
    return unless record.image.attached?

    record.send(:image_variant, record.image).processed
  end
end
