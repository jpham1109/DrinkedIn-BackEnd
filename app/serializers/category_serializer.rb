# frozen_string_literal: true

class CategorySerializer < ActiveModel::Serializer
  attributes :id, :name, :definition, :popular_drinks
  has_many :cocktails
  # override the cocktails method to only return the ids of the cocktails
  class CocktailSerializer < ActiveModel::Serializer
    attributes :id
  end

  def popular_drinks
    Array(object.popular_drinks).map do |drink|
      next drink unless drink.is_a?(Hash)

      drink = drink.stringify_keys
      drink.merge('image' => absolute_image_url(drink['image']))
    end
  end

  private

  def absolute_image_url(image)
    return nil if image.blank?

    path = extract_path(image)
    return nil if path.blank?

    "#{configured_origin}#{path.start_with?('/') ? path : "/#{path}"}"
  end

  # Accepts either a relative path or a legacy absolute URL (possibly with a
  # stale host). Always resolves down to a bare path — never passes a raw
  # absolute URL through — so absolute_image_url can never double-prefix.
  def extract_path(image)
    return image unless image.match?(%r{\Ahttps?://}i)

    URI.parse(image).path
  rescue URI::InvalidURIError
    Rails.logger.warn("CategorySerializer: could not parse popular_drinks image #{image.inspect}")
    nil
  end

  def configured_origin
    options = Rails.application.routes.default_url_options
    host = options[:host]
    raise "default_url_options[:host] is not configured" if host.blank?

    "#{options[:protocol] || 'http'}://#{host}"
  end
end
