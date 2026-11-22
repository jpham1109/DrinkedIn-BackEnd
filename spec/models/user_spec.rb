# frozen_string_literal: true

require 'rails_helper'

RSpec.describe User, type: :model do
  describe 'email' do
    it 'is valid with a unique email' do
      user = build(:user, email: 'person@example.com')
      expect(user).to be_valid
    end

    it 'is invalid with an exact duplicate email' do
      create(:user, email: 'person@example.com')
      user = build(:user, email: 'person@example.com')
      expect(user).not_to be_valid
      expect(user.errors[:email]).to be_present
    end

    it 'is invalid with a case-insensitive duplicate email' do
      create(:user, email: 'Person@Example.com')
      user = build(:user, email: 'person@example.com')
      expect(user).not_to be_valid
      expect(user.errors[:email]).to be_present
    end

    # ai/v1-redesign-plan.md's email-signup-completion workstream
    # (2026-11-22) — User now requires email on: :create
    # (validates :email, presence: true, on: :create). This did not
    # exist when these three examples were first written; see below in
    # this file for the explicit legacy-record (pre-existing nil email)
    # guarantee that replaces what these used to prove.
    it 'is invalid to create a new user with no email' do
      user = build(:user, email: nil)
      expect(user).not_to be_valid
      expect(user.errors[:email]).to be_present
    end

    it 'is invalid with a malformed email' do
      user = build(:user, email: 'not-an-email')
      expect(user).not_to be_valid
      expect(user.errors[:email]).to be_present
    end

    it 'is invalid to create with a blank email' do
      user = build(:user, email: '')
      expect(user).not_to be_valid
      # Proves normalization still runs first (blank -> nil) and the
      # presence check correctly fails on that normalized value, not on
      # the original blank string.
      expect(user.email).to be_nil
      expect(user.errors[:email]).to be_present
    end

    it 'normalizes a whitespace-only email to nil before the presence check runs' do
      user = build(:user, email: '   ')
      expect(user).not_to be_valid
      expect(user.email).to be_nil
      expect(user.errors[:email]).to be_present
    end

    it 'trims incidental surrounding whitespace, preserving casing' do
      user = build(:user, email: '  Person@Example.com  ')
      user.valid?
      expect(user.email).to eq('Person@Example.com')
    end

    it 'enforces the same uniqueness rule at the database level via a unique index' do
      create(:user, email: 'person@example.com')
      user = build(:user, email: 'person@example.com')
      expect do
        user.save(validate: false)
      end.to raise_error(ActiveRecord::RecordNotUnique)
    end
  end

  # ai/v1-redesign-plan.md's email-signup-completion workstream
  # (2026-11-22) — the new presence requirement is scoped to `on:
  # :create` only, so a row that already existed before this
  # requirement (no account-creation flow goes through this today —
  # simulated here via update_column, which bypasses validations
  # entirely, the same technique this codebase's own
  # 20261118000000_update_category_editorial_definitions_v1.rb
  # migration uses to write pre-existing-data changes) must keep
  # working normally.
  describe 'legacy accounts with no email (pre-dating the presence requirement)' do
    # rubocop:disable Rails/SkipsModelValidations -- deliberate: this is
    # the only way to put a row into the exact state this describe block
    # needs to test (a pre-existing nil email, which on: :create would
    # now reject) — the real on: :create validation is never bypassed by
    # anything in actual production code paths, only by this test setup.
    it 'remains valid when updated for something unrelated to email' do
      legacy_user = create(:user)
      legacy_user.update_column(:email, nil)

      expect(legacy_user.reload.update(full_name: 'Updated Name')).to be(true)
      expect(legacy_user.email).to be_nil
    end

    it 'allows multiple legacy nil-email accounts to coexist' do
      first_legacy = create(:user)
      first_legacy.update_column(:email, nil)
      second_legacy = create(:user)
      second_legacy.update_column(:email, nil)

      expect(User.where(email: nil).count).to be >= 2
      expect(second_legacy.reload.update(full_name: 'Still Fine')).to be(true)
    end

    it 'still normalizes email on an update to an existing legacy record' do
      legacy_user = create(:user)
      legacy_user.update_column(:email, nil)

      expect(legacy_user.update(email: '  new.email@example.com  ')).to be(true)
      expect(legacy_user.email).to eq('new.email@example.com')
    end
    # rubocop:enable Rails/SkipsModelValidations
  end
end
