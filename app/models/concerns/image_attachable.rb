# frozen_string_literal: true

module ImageAttachable
  extend ActiveSupport::Concern

  included do
    has_one_attached :image
  end

  def attach_image(image_params)
    return unless image_params

    if image_params.is_a?(ActionDispatch::Http::UploadedFile)
      image.attach(image_params)
    elsif image_params.is_a?(String) && image_params.starts_with?('data:image')
      # decode Base64 image
      decoded_image = Base64.decode64(image_params.split(',')[1])
      image_io = StringIO.new(decoded_image)
      blob = create_blob_from_image(image_io, 'uploaded_image.png', 'image/png')
      image.attach(blob)
    end
  end

  def processed_image_url
    return unless image.attached?

    Rails.application.routes.url_helpers.url_for(process_image(image))
  end

  private

  def process_image(image, _content_type = image.content_type)
    image.variant(
      resize_to_limit: [500, 500],
      convert: 'webp',
      saver: { quality: 80 }
    ).processed
  end

  def create_blob_from_image(image, filename, content_type)
    ActiveStorage::Blob.create_after_upload!(
      io: image,
      filename:,
      content_type:
    )
  end
end
