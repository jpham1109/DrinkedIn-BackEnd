# frozen_string_literal: true

# ai/v1-redesign-plan.md's creator/submitter attribution workstream, B1.
# Purely mechanical: cocktails.bartender_id already means "who
# owns/submitted this record" today (confirmed: no bartender-only gate
# exists anywhere, submitted_by/bartender_id is already always set from
# current_user.id server-side) — this renames it to match that reality,
# preserving every existing row/relationship exactly. Rails' PostgreSQL
# adapter renames the column's own single-column index automatically as
# part of rename_column (confirmed live: an explicit follow-up
# rename_index call failed because the index had already been renamed by
# this point) — the FK constraint likewise follows the renamed column
# automatically in Postgres. Neither needs a separate step here.
class RenameBartenderIdToSubmittedByIdOnCocktails < ActiveRecord::Migration[7.0]
  def change
    rename_column :cocktails, :bartender_id, :submitted_by_id
  end
end
