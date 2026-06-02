# frozen_string_literal: true

module ImageAttachable
  extend ActiveSupport::Concern

  ALLOWED_CONTENT_TYPES = %w[image/jpeg image/png image/webp].freeze
  MAX_FILE_SIZE = 5.megabytes

  included do
    has_one_attached :image
  end

  # Returns an array of human-readable error strings.
  # Empty array means the file is acceptable.
  # For Base64 uploads: content type is accepted based on assigned metadata (image/png);
  # size is validated against the decoded byte count.
  # Byte-level content verification is deferred to a later phase.
  def image_upload_errors(file)
    if file.is_a?(ActionDispatch::Http::UploadedFile)
      errors = []
      errors << 'must be a JPEG, PNG, or WebP image' unless ALLOWED_CONTENT_TYPES.include?(file.content_type)
      errors << 'must be less than 5MB' if file.size > MAX_FILE_SIZE
      errors
    elsif file.is_a?(String) && file.start_with?('data:image')
      decoded_size = Base64.decode64(file.split(',')[1]).bytesize
      decoded_size > MAX_FILE_SIZE ? ['must be less than 5MB'] : []
    else
      []
    end
  end

  def attach_image(image_params)
    return unless image_params

    if image_params.is_a?(ActionDispatch::Http::UploadedFile)
      image.attach(image_params)
    elsif image_params.is_a?(String) && image_params.starts_with?('data:image')
      decoded_image = Base64.decode64(image_params.split(',')[1])
      image_io = StringIO.new(decoded_image)
      blob = create_blob_from_image(image_io, 'uploaded_image.png', 'image/png')
      image.attach(blob)
    end
  end

  def processed_image_url
    return unless image.attached?

    Rails.application.routes.url_helpers.url_for(image_variant(image))
  rescue StandardError => e
    Rails.logger.error "Image processing failed for #{self.class.name} ##{id}: #{e.message}"
    nil
  end

  private

  def image_variant(image, _content_type = image.content_type)
    image.variant(
      resize_to_limit: [500, 500],
      convert: 'webp',
      saver: { quality: 80 }
    )
  end

  def create_blob_from_image(image, filename, content_type)
    ActiveStorage::Blob.create_after_upload!(
      io: image,
      filename:,
      content_type:
    )
  end
end
