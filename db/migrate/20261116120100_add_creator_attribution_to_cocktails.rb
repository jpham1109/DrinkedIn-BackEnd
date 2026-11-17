# frozen_string_literal: true

# ai/v1-redesign-plan.md's creator/submitter attribution workstream, B2.
# Independent creator attribution, deliberately separate from
# submitted_by_id (ownership/submission, renamed in the prior
# migration). Three representable states, never more than one at a
# time: a linked Kinpour user (creator_user_id), an external name
# (creator_name), or an explicit "genuinely unknown/traditional" flag
# (creator_unknown) — all three left unset means "not yet decided",
# which is a valid state for a draft (publication-time readiness is a
# later, separate workstream step, not enforced here).
#
# Does NOT backfill creator_user_id from the existing submitted_by_id
# data on any existing row — per explicit product decision, ownership is
# not verified authorship. Every existing cocktail gets all three
# columns at their default/nil "not yet decided" state.
class AddCreatorAttributionToCocktails < ActiveRecord::Migration[7.0]
  def change
    change_table :cocktails, bulk: true do |t|
      t.references :creator_user, foreign_key: { to_table: :users }, null: true, index: true
      t.string :creator_name
      t.boolean :creator_unknown, null: false, default: false
    end

    add_check_constraint :cocktails,
                         '(creator_user_id IS NOT NULL)::int + (creator_name IS NOT NULL)::int + ' \
                         '(creator_unknown)::int <= 1',
                         name: 'creator_attribution_mutually_exclusive'
  end
end
