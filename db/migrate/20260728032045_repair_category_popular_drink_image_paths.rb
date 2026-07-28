# frozen_string_literal: true

# Data-only migration: existing categories.popular_drinks entries store
# absolute image URLs baked in at seed time (e.g. http://localhost:3000/...),
# which go stale whenever the configured host/port changes. This strips any
# existing origin, leaving a bare relative path, matching the convention
# CategorySerializer now rebuilds full URLs from at read time.
class RepairCategoryPopularDrinkImagePaths < ActiveRecord::Migration[7.0]
  class MigrationCategory < ActiveRecord::Base
    self.table_name = 'categories'
  end

  def up
    MigrationCategory.reset_column_information
    MigrationCategory.find_each do |category|
      repaired = normalize(category.popular_drinks)
      category.update_column(:popular_drinks, repaired) if repaired != category.popular_drinks
    end
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end

  private

  def normalize(popular_drinks)
    Array(popular_drinks).map do |drink|
      drink = drink.is_a?(Hash) ? drink.stringify_keys : {}
      image = drink['image']
      next drink if image.blank?

      path = extract_path(image)
      path.present? ? drink.merge('image' => path.delete_prefix('/')) : drink
    end
  end

  def extract_path(image)
    return image unless image.match?(%r{\Ahttps?://}i)

    URI.parse(image).path
  rescue URI::InvalidURIError
    nil
  end
end
