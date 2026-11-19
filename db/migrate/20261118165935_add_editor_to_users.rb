# frozen_string_literal: true

# ai/v1-redesign-plan.md's editorial-authorization/publication-lifecycle
# workstream (2026-11-18). `editor: true` is currently broad,
# undifferentiated catalog authority for V1 — create/update/destroy/
# publish/unpublish any cocktail, not scoped to specific actions or
# categories. Provisioning a second editor account needs its own
# permissions review before it happens, not just flipping this column.
#
# Never settable through public signup/profile updates
# (UsersController#user_params doesn't permit it — see the comment
# there). Grant procedure for the founder's own account is a documented,
# one-time Rails console step (`User.find_by(username:
# '...').update!(editor: true)`), by username — there is no `email`
# column on `users` yet.
class AddEditorToUsers < ActiveRecord::Migration[7.0]
  def change
    add_column :users, :editor, :boolean, null: false, default: false
  end
end
