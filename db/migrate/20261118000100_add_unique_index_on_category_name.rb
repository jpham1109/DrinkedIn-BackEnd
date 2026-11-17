# frozen_string_literal: true

# ai/v1-redesign-plan.md's category audit, 2026-11-18. Category.name had
# no database-level uniqueness protection at all — confirmed zero
# duplicates exist today (exact or case-insensitive, across all 19 real
# rows) before adding this, so the index can be created directly with
# no backfill/cleanup step needed.
#
# Case-insensitive (functional index on lower(name)), matching
# User#username's existing uniqueness convention (app/models/user.rb) —
# "Tiki" and "tiki" are the same editorial category, not two. Does not
# rename, merge, delete, or renumber any existing Category row; purely
# additive (an index + a matching application-level validation in
# app/models/category.rb). Not built :concurrently — this table has 19
# rows; the brief write-lock a normal index build takes is negligible at
# this size, and :concurrently would only add complexity (a non-
# transactional migration) for no real benefit here.
class AddUniqueIndexOnCategoryName < ActiveRecord::Migration[7.0]
  def change
    add_index :categories, 'lower(name)', unique: true, name: 'index_categories_on_lower_name'
  end
end
