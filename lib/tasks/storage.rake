# frozen_string_literal: true

namespace :storage do
  desc 'Report Active Storage health: missing blob files and existing variant records'
  task verify: :environment do
    blobs = ActiveStorage::Blob.all
    missing_blobs = blobs.reject do |blob|
      blob.service.exist?(blob.key)
    rescue StandardError
      false
    end

    variant_count = ActiveStorage::VariantRecord.count

    puts "Active Storage health check"
    puts "---------------------------"
    puts "Blobs total:          #{blobs.count}"
    puts "Blobs missing files:  #{missing_blobs.count}"
    puts "Variant records:      #{variant_count}"

    if variant_count.positive?
      puts ""
      puts "Note: #{variant_count} variant record(s) exist from previous image processing runs."
      puts "These are normal — they cache processed image variants and are not errors."
    end

    puts ""

    if missing_blobs.any?
      puts "WARNING: #{missing_blobs.count} blob(s) have no backing file in storage/."
      puts ""
      puts "storage/ is gitignored. Blob records in the database point to files"
      puts "that are no longer present. Reseeding alone will not fix this — it"
      puts "creates new blob records but leaves the old stale references in place."
      puts ""
      puts "Fix: reset the database and reseed from scratch."
      puts "  docker compose exec web rails db:reset"
      puts "  docker compose exec web rails db:seed"
    else
      puts "OK: all blobs have backing files."
    end
  end
end
