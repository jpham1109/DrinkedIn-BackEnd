# frozen_string_literal: true

# ai/v1-redesign-plan.md's users.email workstream (2026-11-19). Nullable,
# no default, no backfill — existing accounts simply have no email yet.
# Case-insensitive unique index, combined with the column in one
# migration (matching the creator-attribution migration's precedent of
# column + constraint together when there's no pre-existing data to
# reconcile — unlike the Category migrations, which were split because
# one of them really was a data migration). Postgres unique indexes
# already treat every NULL as distinct from every other NULL, so
# "allowing multiple NULLs" needs no special handling beyond not adding
# NOT NULL. See User#normalize_email for why a blank submission can
# never collide with another blank one under this index.
class AddEmailToUsers < ActiveRecord::Migration[7.0]
  def change
    add_column :users, :email, :string
    add_index :users, 'lower(email)', unique: true, name: 'index_users_on_lower_email'
  end
end
