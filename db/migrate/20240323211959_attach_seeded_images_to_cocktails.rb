class AttachSeededImagesToCocktails < ActiveRecord::Migration[7.0]
  def up
    # seed images
    # Cocktail.all.each do |cocktail|
    #   cocktail.image.attach(io: File.open("app/assets/images/cocktails/#{cocktail.name.downcase.gsub(" ", "_")}.jpg"), filename: "#{cocktail.name.downcase.gsub(" ", "_")}.jpg")
    Cocktail.find_each do |cocktail|
      next unless cocktail.image.present?

      # Construct the image file path 
      file_path = Rails.root.join("public", "photos", "cocktails", cocktail.image.split("/").last)
      if File.exist?(file_path)
        cocktail.photo.attach(io: File.open(file_path), filename: cocktail.image.split("/").last)
      end
    end
  end

  def down
    # If this migration needs to be reversed, detach all attachment.
    Cocktail.find_each { |cocktail| cocktail.photo.purge }
  end
end
