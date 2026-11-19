# frozen_string_literal: true

# ai/v1-redesign-plan.md's publication-lifecycle workstream (2026-11-18).
# Nullable, no default, no backfill — every cocktail, including every
# existing row, is a draft until an editor explicitly publishes it
# (docs/content-publication-policy.md: "Do not automatically publish
# every existing database record"). See Cocktail#published for the
# explicit scope this backs, and CocktailsController#publish/#unpublish
# for the only two places this column is ever written.
class AddPublishedAtToCocktails < ActiveRecord::Migration[7.0]
  def change
    add_column :cocktails, :published_at, :datetime
  end
end
